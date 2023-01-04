from smartfast.core.expressions.expression_typed import ExpressionTyped
from smartfast.core.expressions.expression import Expression
from smartfast.core.solidity_types.type import Type


class TypeConversion(ExpressionTyped):
    def __init__(self, expression, expression_type):
        super().__init__()
        assert isinstance(expression, Expression)
        assert isinstance(expression_type, Type)
        self._expression: Expression = expression
        self._type: Type = expression_type

    @property
    def expression(self) -> Expression:
        return self._expression

    def __str__(self):
        return str(self.type) + "(" + str(self.expression) + ")"
