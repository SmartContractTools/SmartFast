from smartfast.core.variables.local_variable import LocalVariable
from smartfast.core.variables.state_variable import StateVariable

from smartfast.core.declarations.solidity_variables import SolidityVariable

from smartfast.smartir.variables.temporary import TemporaryVariable
from smartfast.smartir.variables.constant import Constant
from smartfast.smartir.variables.reference import ReferenceVariable
from smartfast.smartir.variables.tuple import TupleVariable


def is_valid_rvalue(v):
    return isinstance(
        v,
        (
            StateVariable,
            LocalVariable,
            TemporaryVariable,
            Constant,
            SolidityVariable,
            ReferenceVariable,
        ),
    )


def is_valid_lvalue(v):
    return isinstance(
        v, (StateVariable, LocalVariable, TemporaryVariable, ReferenceVariable, TupleVariable,),
    )
