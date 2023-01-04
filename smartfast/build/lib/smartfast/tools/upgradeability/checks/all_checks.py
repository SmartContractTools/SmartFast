# pylint: disable=unused-import
from smartfast.tools.upgradeability.checks.initialization import (
    InitializablePresent,
    InitializableInherited,
    InitializableInitializer,
    MissingInitializerModifier,
    MissingCalls,
    MultipleCalls,
    InitializeTarget,
)

from smartfast.tools.upgradeability.checks.functions_ids import IDCollision, FunctionShadowing

from smartfast.tools.upgradeability.checks.variable_initialization import VariableWithInit

from smartfast.tools.upgradeability.checks.variables_order import (
    MissingVariable,
    DifferentVariableContractProxy,
    DifferentVariableContractNewContract,
    ExtraVariablesProxy,
    ExtraVariablesNewContract,
)

from smartfast.tools.upgradeability.checks.constant import WereConstant, BecameConstant
