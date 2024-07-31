import boto3


class Logger:
    def __init__(self, request: dict, sender_ip: str):
        self.request = request
        self.sender_ip = sender_ip

    def out(self, status: str) -> dict:
        return {
            "request": self.request,
            "sender_ip": self.sender_ip,
            "status": status
        }


class SSM:
    def __init__(self, parameter_prefix: str):
        if parameter_prefix is None or parameter_prefix == "":
            raise ValueError("Invalid parameter prefix")
        self.parameter_prefix = parameter_prefix

    def get(self, param: str) -> str | None:
        client = boto3.client('ssm')
        try:
            response = client.get_parameter(
                Name=f"/{self.parameter_prefix}/{param}"
            )
            return response['Parameter']['Value']
        except client.exceptions.ParameterNotFound:
            return None

    def set(self, param: str, value: str) -> None:
        client = boto3.client('ssm')
        client.put_parameter(
            Name=f"/{self.parameter_prefix}/{param}",
            Value=value,
            Type="String",
            Overwrite=True
        )

    @property
    def always_flag(self) -> bool:
        try:
            value = self.get("always-flag")
        except self.client.exceptions.ClientError:
            raise ValueError("Invalid Configuration")
        return True if value == "true" else False

    @always_flag.setter
    def always_flag(self, value: bool) -> None:
        try:
            if not value:
                self.set("always-flag", "false")
                return
            self.set("always-flag", "true")
            return
        except self.client.exceptions.ClientError:
            raise ValueError("Invalid Configuration")

    @property
    def bypass_flagger(self) -> bool:
        try:
            value = self.get("bypass-flagger")
        except self.client.exceptions.ClientError:
            raise ValueError("Invalid Configuration")
        return True if value == "true" else False

    @bypass_flagger.setter
    def bypass_flagger(self, value: bool) -> None:
        try:
            if not value:
                self.set("bypass-flagger", "false")
                return
            self.set("bypass-flagger", "true")
            return
        except self.client.exceptions.ClientError:
            raise ValueError("Invalid Configuration")

    def get_all_values(self) -> dict:
        try:
            return {
                "always_flag": self.always_flag,
                "bypass_flagger": self.bypass_flagger
            }
        except ValueError as e:
            raise ValueError(str(e))
