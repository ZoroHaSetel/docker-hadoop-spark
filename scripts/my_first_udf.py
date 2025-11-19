from pig_util import outputSchema
@outputSchema("value:int")
def return_one(value):
    return 1