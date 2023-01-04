from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from smartfast import Smartfast


class ChildSmartfast:
    def __init__(self):
        super().__init__()
        self._smartfast = None

    def set_smartfast(self, smartfast: "Smartfast"):
        self._smartfast = smartfast

    @property
    def smartfast(self) -> "Smartfast":
        return self._smartfast
