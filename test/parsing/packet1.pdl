[
    {
        "variable_length": true, 
        "id_path": "/host_serial", 
        "delimiter": 124,
        "name": "yy.accounting.req1", 
        "method_path": "/trade_code", 
        "has_length": false, 
        "length_path": "/length",
        "content": [
            {
                "note": "", 
                "variable_length": false, 
                "node_type": "field", 
                "min_length": 1, 
                "max_length": 4, 
                "name": "length", 
                "required": true, 
                "label": "Packet Length",
                "pipeline": ["atoi"]
            }, 
            {
                "node_type": "constant", 
                "value": "|"
            }, 
            {
                "note": "", 
                "variable_length": false, 
                "node_type": "field", 
                "max_length": 20, 
                "min_length": 1, 
                "name": "trade_code", 
                "required": true, 
                "label": "Trade code"
            }, 
            {
                "node_type": "constant", 
                "value": "|"
            }, 
            {
                "note": "", 
                "node_type": "field", 
                "max_length": 20, 
                "min_length": 1, 
                "variable_length": true, 
                "name": "host_serial", 
                "required": true, 
                "label": "Host Journal Serial"
            }, 
            {
                "node_type": "constant", 
                "value": "|"
            }, 
            {
                "note": "", 
                "variable_length": true, 
                "node_type": "field", 
                "max_length": 100, 
                "min_length": 1, 
                "name": "host_msg", 
                "required": true, 
                "label": "Host Message"
            }, 
            {
                "node_type": "constant", 
                "value": "|"
            }, 
            {
                "node_type": "group", 
                "required": true, 
                "children": [
                {
                    "variable_length": true, 
                    "node_type": "field", 
                    "name": "credit_account", 
                    "max_length": 30, 
                    "min_length": 1,
                    "required": true, 
                    "label": "Credit Account"
                }, 
                {
                    "node_type": "constant", 
                    "value": "|"
                }, 
                {
                    "variable_length": true, 
                    "node_type": "field", 
                    "name": "debit_account", 
                    "max_length": 30, 
                    "min_length": 1,
                    "required": true, 
                    "label": "Debit Account"
                }, 
                {
                    "node_type": "constant", 
                    "value": "|"
                }, 
                {
                    "variable_length": true, 
                    "node_type": "field", 
                    "name": "amount", 
                    "required": true, 
                    "label": "Amount",
                    "max_length": 16, 
                    "min_length": 1,
                    "pipeline": ["atod"]
                }, 
                {
                    "node_type": "constant", 
                    "value": "|"
                }
                ], 
                    "name": "details", 
                    "label": "Account Move Details"
            }, 
            {
                "node_type": "constant", 
                "value": "|"
            }
        ] 
    }
]
