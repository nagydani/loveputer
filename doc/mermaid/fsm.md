```mermaid
stateDiagram-v2
  direction LR

  classDef editorStyle fill:#FF8815, color:#000;
  class editor editorStyle
  classDef inspectStyle fill:#FF4315, color:#000;
  class inspect inspectStyle
  classDef runStyle fill:#5BFF15, color:#000;
  class running runStyle

  %% linkStyle default stroke:red
  %% linkStyle 0 stroke-width:4px,stroke:green
  %% linkStyle 3 stroke:blue
  %% linkStyle 4 stroke:blue

  state init {
    [*] --> booting
    booting --> title
    title --> ready
  }
  ready --> project_open     : project()
  ready --> running          : run_project()
  running --> project_open   : quit()
  running --> inspect        : stop()
  inspect --> running        : continue()
  running --> ready
  project_open --> ready     : close_project()
  project_open --> editor    : edit()
  inspect --> editor         : edit()
  editor --> inspect         : finish_edit()
```
