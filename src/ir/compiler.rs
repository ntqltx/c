#![allow(dead_code)]
use super::{
	OpCode,
	value::{Value, alloc_obj_string}
};
use crate::lexer::{
	expr::Expr,
	LiteralValue,
	TokenType::*
};

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

	pub fn emit_expr(&mut self, expr: &Expr) {
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
				self.emit_expr(left);
				self.emit_expr(right);

				match operator.token_type {
					Plus => self.add_op(OpCode::Add),
					Minus => self.add_op(OpCode::Sub),
					Star => self.add_op(OpCode::Mul),
					Slash => self.add_op(OpCode::Div),
					_ => todo!(),
				}
			}
			Expr::Unary { operator, right } => {
				self.emit_expr(right);

				match operator.token_type {
					Minus => self.add_op(OpCode::Negate),
					_ => todo!(),
				}
			}
			Expr::Grouping(expr) => self.emit_expr(expr),
		}
	}

	pub fn emit_print(&mut self, expr: &Expr) {
		self.emit_expr(expr);
		self.add_op(OpCode::Print);
	}

	// for repl we're adding OpCode::Pop
	pub fn emit_expression(&mut self, expr: &Expr) {
		self.emit_expr(expr);
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