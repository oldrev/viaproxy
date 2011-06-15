{
    "variable_length": true, 
    "id_path": "/host_serial", 
    "delimiter": [124],
    "name": "yy.accounting.req1", 
    "method_path": "/trade_code", 
    "content": {
        "node_type": "container", 
        "required": true, 
        "children": [
            {
                "note": "", 
                "variable_length": false, 
                "node_type": "field", 
                "max_length": 4, 
                "name": "length", 
                "converter": "str2int", 
                "required": true, 
                "char_type": "nums", 
                "label": "Packet Length"
            }, 
            {
                "node_type": "constants", 
                "value": "|"
            }, 
            {
                "note": "", 
                "variable_length": false, 
                "node_type": "field", 
                "max_length": 4, 
                "name": "trade_code", 
                "converter": "ascii2str", 
                "required": true, 
                "char_type": "alphanums", 
                "label": "Trade code"
            }, 
            {
                "node_type": "constants", 
                "value": "|"
            }, 
            {
                "note": "", 
                "node_type": "field", 
                "max_length": 4, 
                "variable_length": true, 
                "name": "host_serial", 
                "converter": "ascii2str", 
                "required": true, 
                "char_type": "alphanums", 
                "label": "Host Journal Serial"
            }, 
            {
                "node_type": "constants", 
                "value": "|"
            }, 
            {
                "note": "", 
                "variable_length": true, 
                "node_type": "field", 
                "max_length": 100, 
                "name": "host_msg", 
                "converter": "gbk2str", 
                "required": true, 
                "char_type": "string", 
                "label": "Host Message"
            }, 
            {
                "node_type": "constants", 
                "value": "|"
            }, 
            {
                "node_type": "container", 
                "required": true, 
                "children": [
                    {
                        "variable_length": true, 
                        "node_type": "field", 
                        "name": "credit_account", 
                        "converter": "ascii2str", 
                        "required": true, 
                        "char_type": "alphanums", 
                        "label": "Credit Account"
                    }, 
                    {
                        "node_type": "constants", 
                        "value": "|"
                    }, 
                    {
                        "variable_length": true, 
                        "node_type": "field", 
                        "name": "debit_account", 
                        "converter": "ascii2str", 
                        "required": true, 
                        "char_type": "alphanums", 
                        "label": "Debit Account"
                    }, 
                    {
                        "node_type": "constants", 
                        "value": "|"
                    }, 
                    {
                        "variable_length": true, 
                        "node_type": "field", 
                        "name": "amount", 
                        "converter": "ascii2dec", 
                        "required": true, 
                        "char_type": "decimal", 
                        "label": "Amount"
                    }, 
                    {
                        "node_type": "constants", 
                        "value": "|"
                    }
                ], 
                "name": "details", 
                "label": "Account Move Details"
            }, 
            {
                "node_type": "constants", 
                "value": "|"
            }
        ], 
        "name": "content", 
        "label": "Whole Package"
    }, 
    "has_length": false, 
    "length_path": "/length"
}
