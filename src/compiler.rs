#![allow(dead_code)]
use crate::expr::Expr;
use crate::tokens::{LiteralValue::*, TokenType::*};

#[repr(u8)]
pub enum OpCode {
	Constant = 0,
	Add,
	Sub,
	Mul,
	Div,
	Negate,
	Return,
}

pub struct Compiler {
	code: Vec<u8>,
	constants: Vec<f64>,
}

impl Compiler {
	pub fn new() -> Self {
		Self {
			code: vec![],
			constants: vec![],
		}
	}

	pub fn compile_expr(&mut self, expr: &Expr) {
		match expr {
			Expr::Literal(value) => match value {
				NumberValue(n) => self.add_constant(*n),
				StringValue(_s) => todo!(),
				_ => todo!(),
			},
			Expr::Binary {
				left,
				operator,
				right,
			} => {
				self.compile_expr(left);
				self.compile_expr(right);

				match operator.token_type {
					Plus => self.add_op(OpCode::Add),
					Minus => self.add_op(OpCode::Sub),
					Star => self.add_op(OpCode::Mul),
					Slash => self.add_op(OpCode::Div),
					_ => todo!(),
				}
			}
			_ => todo!(),
		}
	}

	pub fn finish(mut self) -> (Vec<u8>, Vec<f64>) {
		self.add_op(OpCode::Return);
		(self.code, self.constants)
	}

	fn add_constant(&mut self, value: f64) {
		self.constants.push(value);

		let idx = self.previous_idx();
		self.add_op(OpCode::Constant);

		self.code.push(idx as u8)
	}

	fn add_op(&mut self, op: OpCode) {
		self.code.push(op as u8)
	}

	fn previous_idx(&self) -> usize {
		self.constants.len() - 1
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	use crate::tokens::{LiteralValue, Token};

	#[test]
	fn number_literal_emits_constant() {
		let mut c = Compiler::new();
		c.compile_expr(&Expr::Literal(NumberValue(42.0)));

		assert_eq!(c.constants, [42.0]);
		assert_eq!(c.code, [OpCode::Constant as u8, 0]);
	}

	#[test]
	fn two_constants_get_sequential_indices() {
		let mut c = Compiler::new();
		c.compile_expr(&Expr::Literal(NumberValue(1.0)));
		c.compile_expr(&Expr::Literal(NumberValue(2.0)));

		assert_eq!(c.constants, [1.0, 2.0]);
		assert_eq!(
			c.code,
			[OpCode::Constant as u8, 0, OpCode::Constant as u8, 1]
		);
	}

	#[test]
	fn binary_add_emits_correct_bytes() {
		let mut c = Compiler::new();
		c.compile_expr(&Expr::Binary {
			left: Box::new(Expr::Literal(NumberValue(1.0))),
			operator: Token {
				token_type: Plus,
				lexeme: "+".to_string(),
				literal: None,
				line_number: 1,
			},
			right: Box::new(Expr::Literal(NumberValue(2.0))),
		});

		assert_eq!(c.constants, [1.0, 2.0]);
		assert_eq!(
			c.code,
			[
				OpCode::Constant as u8,
				0,
				OpCode::Constant as u8,
				1,
				OpCode::Add as u8,
			]
		);
	}

	#[test]
	#[should_panic]
	fn non_number_literal_is_noop() {
		let mut c = Compiler::new();
		c.compile_expr(&Expr::Literal(LiteralValue::True));

		assert!(c.code.is_empty());
		assert!(c.constants.is_empty());
	}
}
