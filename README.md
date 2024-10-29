## README

This project is in an unfinished state. It is meant operate as a simplistic front end for a fitness assistant that leverages generative AI. 

The assistant is based on a RAG architecture on top of OpenAI. We leverage OpenAI's Assistant API to create and manage an assistant (essentially a persistent instantiation of a GPT that has a preset instructions and can be run on any thread history), as well as OpenAI's implementation of a vector store to allow for efficient retrieval of workout history data. Additionally, the setup leverages function-calling in order to make modifications to the persistent data in the app for UI updates and interactability.

Below is a high-level view of the assistant architecture: 

![image](https://github.com/user-attachments/assets/b8b08f05-7672-4cf4-97fe-121ca7a86359)
