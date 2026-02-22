# House of docker

developer experience repository.

## Running the app

Run the whole process, Simply type:

```bash
make up
```

Stop everything:

```bash
make down
```

To generate a new Sponsor address, delete config.yaml file:

```bash
rm config.yaml
```

## Install via Homebrew

You can install the scripts and Compose assets into Homebrew using the included formula:

```bash
brew install --build-from-source ./Formula/house-of-docker.rb
```

That places the helper script on your `$PATH` as `gas-station-tool` and the project files inside `$(brew --prefix)/share/house-of-docker`. To start working with the stack:

```bash
mkdir -p ~/house-of-docker
cp -R "$(brew --prefix)/share/house-of-docker/." ~/house-of-docker
cd ~/house-of-docker
make up
```
