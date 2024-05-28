# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

import json
from typing import List, Optional

from ufo.config.config import Config

configs = Config.get_instance().config_data


class PlanReader:
    """
    The reader for a plan file.
    """

    def __init__(self, plan_file: str):
        """
        Initialize a plan reader.
        :param plan_file: The path of the plan file.
        """

        with open(plan_file, "r") as f:
            self.plan = json.load(f)
        self.remaining_steps = self.get_steps()

    def get_task(self) -> str:
        """
        Get the task name.
        :return: The task name.
        """

        return self.plan.get("task", "")

    def get_steps(self) -> List[str]:
        """
        Get the steps in the plan.
        :return: The steps in the plan.
        """

        return self.plan.get("steps", [])

    def get_operation_object(self) -> str:
        """
        Get the operation object in the step.
        :return: The operation object.
        """

        return self.plan.get("object", "")

    def get_initial_request(self) -> str:
        """
        Get the initial request in the plan.
        :return: The initial request.
        """

        task = self.get_task()
        object_name = self.get_operation_object()

        request = f"{task} in {object_name}"

        return request

    def get_host_agent_request(self) -> str:
        """
        Get the request for the host agent.
        :return: The request for the host agent.
        """

        object_name = self.get_operation_object()

        request = (
            f"Open and select the application of {object_name}, and output the FINISH status immediately. "
            "You must output the selected application with their control text and label even if it is already open."
        )

        return request

    def next_step(self) -> Optional[str]:
        """
        Get the next step in the plan.
        :return: The next step.
        """

        if self.remaining_steps:
            step = self.remaining_steps.pop(0)
            return step

        return None

    def task_finished(self) -> bool:
        """
        Check if the task is finished.
        :return: True if the task is finished, False otherwise.
        """

        return not self.remaining_steps
