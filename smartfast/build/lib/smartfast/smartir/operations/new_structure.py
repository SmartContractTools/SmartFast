from smartfast.smartir.operations.call import Call
from smartfast.smartir.operations.lvalue import OperationWithLValue

from smartfast.smartir.utils.utils import is_valid_lvalue

from smartfast.core.declarations.structure import Structure


class NewStructure(Call, OperationWithLValue):
    def __init__(self, structure, lvalue):
        super().__init__()
        assert isinstance(structure, Structure)
        assert is_valid_lvalue(lvalue)
        self._structure = structure
        # todo create analyze to add the contract instance
        self._lvalue = lvalue

    @property
    def read(self):
        return self._unroll(self.arguments)

    @property
    def structure(self):
        return self._structure

    @property
    def structure_name(self):
        return self.structure.name

    def __str__(self):
        args = [str(a) for a in self.arguments]
        return "{} = new {}({})".format(self.lvalue, self.structure_name, ",".join(args))
