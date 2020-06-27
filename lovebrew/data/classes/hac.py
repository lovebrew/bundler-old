from .console import Console

class HAC(Console):

    def __init__(self, data):
        super().__init__(data)
        self.build()

    def build(self):
        super().build()

    def __str__(self):
        return "Nintendo Switch"
