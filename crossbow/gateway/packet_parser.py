import re


packet1 = {
    "has_length": False,
    "variable_length": True,
    "method_path": "/trade_code",
    "length_path": "/length",
    "id_path": "/host_serial",

    "content" : {
        "name": "content",
        "label": "Whole Package",
        "node_type": "container",
        "required": True,
        "children": [
            {
                "name": "length",
                "label": "Packet Length",
                "node_type": "field",
                "note": "",
                "variable_length": False,
                "max_length": 4,
                "converter": "str2int",
            },
            {
                "node_type": "constants",
                "value": ord("|"),
            },
            {
                "name": "trade_code",
                "label": "Trade code",
                "node_type": "field",
                "note": "",
                "variable_length": False,
                "max_length": 4,
                "converter": "ascii2str",
            },
            {
                "node_type": "constants",
                "value": ord("|"),
            },
            {
                "name": "host_serial",
                "label": "Host Journal Serial",
                "node_type": "field",
                "regex": r"\w",
                "note": "",
                "variable_length": True,
                "max_length": 4,
                "converter": "ascii2str",
            },
            {
                "node_type": "constants",
                "value": ord("|"),
            },
            {
                "name": "details",
                "label": "Account Move Details",
                "node_type": "container",
                "required": True,
                "children": [
                    {
                        "name": "credit_account",
                        "label": "Credit Account",
                        "node_type": "field",
                        "regex": r"\w",
                        "variable_length": True,
                        "converter": "ascii2str",
                    },
                    {
                        "node_type": "constants",
                        "value": ord("|"),
                    },
                    {
                        "name": "debit_account",
                        "label": "Debit Account",
                        "node_type": "field",
                        "regex": r"\w",
                        "variable_length": True,
                        "converter": "ascii2str",
                    },
                    {
                        "node_type": "constants",
                        "value": ord("|"),
                    },
                    {
                        "name": "amount",
                        "label": "Amount",
                        "node_type": "field",
                        "regex": r"[\d\.]",
                        "variable_length": True,
                        "converter": "ascii2dec",
                    },
                ],
            },
            {
                "node_type": "constants",
                "value": ord("|"),
            },
        ]
    }
}

string = b"123|9700|S20110613002|A123|A321|12.4|A111|A222|32.2|A333|A444|32.2|";
p1 = StringIO.StringIO(string)


