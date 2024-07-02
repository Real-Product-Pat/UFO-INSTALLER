# HostAgent 🤖

The `HostAgent` assumes three primary responsibilities:

1. **User Engagement**: The `HostAgent` engages with the user to understand their request and analyze their intent. It also conversates with the user to gather additional information when necessary.
2. **AppAgent Management**: The `HostAgent` manages the creation and registration of `AppAgents` to fulfill the user's request. It also orchestrates the interaction between the `AppAgents` and the application.
3. **Task Management**: The `HostAgent` analyzes the user's request, to decompose it into sub-tasks and distribute them among the `AppAgents`. It also manages the scheduling, orchestration, coordination, and monitoring of the `AppAgents` to ensure the successful completion of the user's request.
4. **Communication**: The `HostAgent` communicates with the `AppAgents` to exchange information. It also manages the `Blackboard` to store and share information among the agents, as shown below:

<h1 align="center">
    <img src="../../img/blackboard.png" alt="Blackboard Image" width="80%">
</h1>


The `HostAgent` activates its `Processor` to process the user's request and decompose it into sub-tasks. Each sub-task is then assigned to an `AppAgent` for execution. The `HostAgent` monitors the progress of the `AppAgents` and ensures the successful completion of the user's request.

## HostAgent Input

The `HostAgent` receives the following inputs:

| Input | Description | Type |
| --- | --- | --- |
| User Request | The user's request in natural language. | String |
| Application Information | Information about the existing active applications. | List of Strings |
| Desktop Screenshots | Screenshots of the desktop to provide context to the `HostAgent`. | Image |
| Previous Sub-Tasks | The previous sub-tasks and their completion status. | List of Strings |
| Previous Plan | The previous plan for the following sub-tasks. | List of Strings |
| Blackboard | The shared memory space for storing and sharing information among the agents. | Dictionary |

By processing these inputs, the `HostAgent` determines the appropriate application to fulfill the user's request and orchestrates the `AppAgents` to execute the necessary actions.

## HostAgent Output

With the inputs provided, the `HostAgent` generates the following outputs:

| Output | Description | Type |
| --- | --- | --- |
| Observation | The observation of current desktop screenshots. | String |
| Thought | The logical reasoning process of the `HostAgent`. | String |
| Current Sub-Task | The current sub-task to be executed by the `AppAgent`. | String |
| Message | The message to be sent to the `AppAgent` for the completion of the sub-task. | String |
| ControlLabel | The index of the selected application to execute the sub-task. | String |
| ControlText | The name of the selected application to execute the sub-task. | String |
| Plan | The plan for the following sub-tasks after the current sub-task. | List of Strings |
| Status | The status of the agent, mapped to the `AgentState`. | String |
| Comment | Additional comments or information provided to the user. | String |
| Questions | The questions to be asked to the user for additional information. | List of Strings |
| AppsToOpen | The application to be opened to execute the sub-task if it is not already open. | Dictionary |


Below is an example of the `HostAgent` output:

```json
{
    "Observation": "Desktop screenshot",
    "Thought": "Logical reasoning process",
    "Current Sub-Task": "Sub-task description",
    "Message": "Message to AppAgent",
    "ControlLabel": "Application index",
    "ControlText": "Application name",
    "Plan": ["Sub-task 1", "Sub-task 2"],
    "Status": "AgentState",
    "Comment": "Additional comments",
    "Questions": ["Question 1", "Question 2"],
    "AppsToOpen": {"APP": "powerpnt", "file_path": ""}
}
```

!!! info
    The `HostAgent` output is formatted as a JSON object by LLMs and can be parsed by the `json.loads` method in Python.


## HostAgent State

The `HostAgent` progresses through different states, as defined in the `ufo/agents/states/host_agent_states.py` module. The states include:

| State | Description |
| --- | --- |
| `CONTINUE` | The `HostAgent` is ready to process the user's request and emloy the `Processor` to decompose it into sub-tasks and assign them to the `AppAgents`. |
| `FINISH` | The overall task is completed, and the `HostAgent` is ready to return the results to the user. |
| `ERROR` | An error occurred during the processing of the user's request, and the `HostAgent` is unable to proceed. |
| `FAIL` | The `HostAgent` believes the task is unachievable and cannot proceed further. |
| `PENDING` | The `HostAgent` is waiting for additional information from the user to proceed. |
<!-- | `CONFIRM` | The `HostAgent` is confirming the user's request before proceeding. | -->

The state machine diagram for the `HostAgent` is shown below:
<h1 align="center">
    <img src="../../img/host_state_machine.png"/> 
</h1>


The `HostAgent` transitions between these states based on the user's request, the application information, and the progress of the `AppAgents` in executing the sub-tasks.


## Task Decomposition
Upon receiving the user's request, the `HostAgent` decomposes it into sub-tasks and assigns each sub-task to an `AppAgent` for execution. The `HostAgent` determines the appropriate application to fulfill the user's request based on the application information and the user's request. It then orchestrates the `AppAgents` to execute the necessary actions to complete the sub-tasks. We show the task decomposition process in the following figure:

<h1 align="center">
    <img src="../../img/desomposition.png" alt="Task Decomposition Image" width="100%">
</h1>

## Creating and Registering AppAgents
When the `HostAgent` determines the need for a new `AppAgent` to fulfill a sub-task, it creates an instance of the `AppAgent` and registers it with the `HostAgent`, by calling the `create_subagent` method:

```python
def create_subagent(
        self,
        agent_type: str,
        agent_name: str,
        process_name: str,
        app_root_name: str,
        is_visual: bool,
        main_prompt: str,
        example_prompt: str,
        api_prompt: str,
        *args,
        **kwargs,
    ) -> BasicAgent:
        """
        Create an SubAgent hosted by the HostAgent.
        :param agent_type: The type of the agent to create.
        :param agent_name: The name of the SubAgent.
        :param process_name: The process name of the app.
        :param app_root_name: The root name of the app.
        :param is_visual: The flag indicating whether the agent is visual or not.
        :param main_prompt: The main prompt file path.
        :param example_prompt: The example prompt file path.
        :param api_prompt: The API prompt file path.
        :return: The created SubAgent.
        """
        app_agent = self.agent_factory.create_agent(
            agent_type,
            agent_name,
            process_name,
            app_root_name,
            is_visual,
            main_prompt,
            example_prompt,
            api_prompt,
            *args,
            **kwargs,
        )
        self.appagent_dict[agent_name] = app_agent
        app_agent.host = self
        self._active_appagent = app_agent

        return app_agent
```

The `HostAgent` then assigns the sub-task to the `AppAgent` for execution and monitors its progress.

# Reference

:::agents.agent.host_agent.HostAgent
