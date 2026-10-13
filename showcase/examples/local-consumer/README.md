# Local consumer proof

A minimal Godot project that instances production resources at their public paths.
From the monorepo root:

```sh
python3 tools/workspace.py install --destination showcase/examples/local-consumer
godot --headless --editor --path showcase/examples/local-consumer --import --quit
godot --path showcase/examples/local-consumer
```

Only UI Kit is installed. The two optional theme packages, catalogue and tests
are excluded. The install manifest records every source checksum. For an exact
revision, check out that monorepo commit before installing. Package build work
must exclude the materialized UI Kit from the published Package artifact.
