[
    {
        "type": "VNewCall",
        "filename": "./compass-bundle.js",
        "vuln_type": "command-injection",
        "sink": "exec(command, function(error, stdout, stderr) {",
        "sink_lineno": 25,
        "source": "new module.exports",
        "tainted_params": [],
        "params_types": {},
        "returns": {
            "source": ".compile",
            "params_types": {
                "options": {
                    "compassCommad" : "string"
                }
            },
            "tainted_params": [
                "options"
            ]
        },
        "call_paths": [
            {
                "type": "New",
                "fn_name": "459.v25-o89",
                "fn_id": "335",
                "source_fn_id": "335"
            },
            {
                "type": "Method",
                "prop": "compile",
                "fn_name": "459.v38-o88",
                "fn_id": 356,
                "source_fn_id": 356
            }
        ]
    }
]
