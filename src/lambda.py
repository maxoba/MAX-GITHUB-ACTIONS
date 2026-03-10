#!/usr/bin/env python3.8
import json
from os import environ
from logging import getLogger


LOG_LEVEL = environ.get("LOG_LEVEL", "INFO")
LOGGER = getLogger()
LOGGER.setLevel(LOG_LEVEL)

def lambda_handler(event, context):
    records = event["Records"]
    for record in records:
        content = record["body"]
        LOGGER.info(json.dumps(content))