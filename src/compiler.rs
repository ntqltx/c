#![allow(dead_code)]
use crate::Value;
use crate::expr::Expr;
use crate::tokens::{LiteralValue, TokenType::*};
use crate::value::alloc_obj_string;

#[repr(u8)]
pub enum OpCode {
	Constant = 0,
	Add, Sub, Mul, Div,
	Print,
	Pop,
	Negate,
	Return,
}

pub struct Compiler {
	code: Vec<u8>,
	constants: Vec<Value>,
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
				LiteralValue::NumberValue(n) => self.add_constant(Value::number(*n)),
				LiteralValue::StringValue(s) => {
					self.add_constant(Value::obj(alloc_obj_string(s)))
				}
				LiteralValue::True => self.add_constant(Value::bool(true)),
				LiteralValue::False => self.add_constant(Value::bool(false)),
				LiteralValue::Nil => self.add_constant(Value::NIL),
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
			Expr::Unary { operator, right } => {
				self.compile_expr(right);

				match operator.token_type {
					Minus => self.add_op(OpCode::Negate),
					_ => todo!(),
				}
			}
			Expr::Grouping(expr) => self.compile_expr(expr),
		}
	}

	pub fn compile_print(&mut self, expr: &Expr) {
		self.compile_expr(expr);
		self.add_op(OpCode::Print);
	}

	pub fn compile_expression_stmt(&mut self, expr: &Expr) {
		self.compile_expr(expr);
		self.add_op(OpCode::Pop);
	}

	pub fn finish(mut self) -> (Vec<u8>, Vec<Value>) {
		self.add_op(OpCode::Return);
		(self.code, self.constants)
	}

	fn add_constant(&mut self, value: Value) {
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

// #[cfg(test)]
// mod tests {
// 	use super::*;
// 	use crate::tokens::{LiteralValue, LiteralValue::*, Token};

// 	#[test]
// 	fn number_literal_emits_constant() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Literal(NumberValue(42.0)));

// 		assert_eq!(c.constants, [CValue::Number(42.0)]);
// 		assert_eq!(c.code, [OpCode::Constant as u8, 0]);
// 	}

// 	#[test]
// 	fn two_constants_get_sequential_indices() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Literal(NumberValue(1.0)));
// 		c.compile_expr(&Expr::Literal(NumberValue(2.0)));

// 		assert_eq!(c.constants, [CValue::Number(1.0), CValue::Number(2.0)]);
// 		assert_eq!(
// 			c.code,
// 			[OpCode::Constant as u8, 0, OpCode::Constant as u8, 1]
// 		);
// 	}

// 	#[test]
// 	fn binary_add_emits_correct_bytes() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Binary {
// 			left: Box::new(Expr::Literal(NumberValue(1.0))),
// 			operator: Token {
// 				token_type: Plus,
// 				lexeme: "+".to_string(),
// 				literal: None,
// 				line_number: 1,
// 			},
// 			right: Box::new(Expr::Literal(NumberValue(2.0))),
// 		});

// 		assert_eq!(c.constants, [CValue::Number(1.0), CValue::Number(2.0)]);
// 		assert_eq!(
// 			c.code,
// 			[
// 				OpCode::Constant as u8,
// 				0,
// 				OpCode::Constant as u8,
// 				1,
// 				OpCode::Add as u8,
// 			]
// 		);
// 	}

// 	#[test]
// 	#[should_panic]
// 	fn non_number_literal_is_noop() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Literal(LiteralValue::True));

// 		assert!(c.code.is_empty());
// 		assert!(c.constants.is_empty());
// 	}

// 	#[test]
// 	fn grouping_emits_inner_expr() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Grouping(Box::new(Expr::Literal(NumberValue(7.0)))));

// 		assert_eq!(c.constants, [CValue::Number(7.0)]);
// 		assert_eq!(c.code, [OpCode::Constant as u8, 0]);
// 	}

// 	#[test]
// 	fn grouping_with_binary_emits_correct_bytes() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Grouping(Box::new(Expr::Binary {
// 			left: Box::new(Expr::Literal(NumberValue(1.0))),
// 			operator: Token {
// 				token_type: Star,
// 				lexeme: "*".to_string(),
// 				literal: None,
// 				line_number: 1,
// 			},
// 			right: Box::new(Expr::Literal(NumberValue(2.0))),
// 		})));

// 		assert_eq!(c.constants, [CValue::Number(1.0), CValue::Number(2.0)]);
// 		assert_eq!(
// 			c.code,
// 			[
// 				OpCode::Constant as u8,
// 				0,
// 				OpCode::Constant as u8,
// 				1,
// 				OpCode::Mul as u8,
// 			]
// 		);
// 	}

// 	#[test]
// 	fn grouping_nil_literal() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Grouping(Box::new(Expr::Literal(LiteralValue::Nil))));
// 	}

// 	#[test]
// 	fn unary_negate_emits_correct_bytes() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Unary {
// 			operator: Token {
// 				token_type: Minus,
// 				lexeme: "-".to_string(),
// 				literal: None,
// 				line_number: 1,
// 			},
// 			right: Box::new(Expr::Literal(NumberValue(5.0))),
// 		});

// 		assert_eq!(c.constants, [CValue::Number(5.0)]);
// 		assert_eq!(c.code, [OpCode::Constant as u8, 0, OpCode::Negate as u8]);
// 	}

// 	#[test]
// 	fn double_negate_stacks_ops() {
// 		let mut c = Compiler::new();
// 		c.compile_expr(&Expr::Unary {
// 			operator: Token {
// 				token_type: Minus,
// 				lexeme: "-".to_string(),
// 				literal: None,
// 				line_number: 1,
// 			},
// 			right: Box::new(Expr::Unary {
// 				operator: Token {
// 					token_type: Minus,
// 					lexeme: "-".to_string(),
// 					literal: None,
// 					line_number: 1,
// 				},
// 				right: Box::new(Expr::Literal(NumberValue(3.0))),
// 			}),
// 		});

// 		assert_eq!(c.constants, [CValue::Number(3.0)]);
// 		assert_eq!(
// 			c.code,
// 			[
// 				OpCode::Constant as u8,
// 				0,
// 				OpCode::Negate as u8,
// 				OpCode::Negate as u8,
// 			]
// 		);
// 	}
// }
