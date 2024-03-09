import json

def find_in_json(obj, key_to_find):
    results = []

    def traverse(current_obj):
        if isinstance(current_obj, dict):
            for key, value in current_obj.items():
                if key == key_to_find:
                    results.append(value)
                else:
                    traverse(value)
        elif isinstance(current_obj, list):
            for item in current_obj:
                traverse(item)

    traverse(obj)
    return results

