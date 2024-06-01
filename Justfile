
# Define variables
containers := "fedora-1 fedora-2"
ssh_key := ".ssh/id_ed25519"
image_name := "fedora_ssh"
inventory_file := "inventory.yaml"
ssh_config := ".ssh/config"


# Rule to generate SSH keys
generate-ssh-keys:
    [ -f {{ssh_key}} ] || ssh-keygen -t ed25519 -f {{ssh_key}} -N ""

# Rule to build the Docker image
build-image:
    docker build -t {{image_name}} .

# Rule to create and start containers
start-containers:
    docker network create ansible-net || true
    for container in {{containers}}; do \
        docker run -d --name $container --network ansible-net {{image_name}}; \
    done

# Rule to inspect container IPs and update inventory file
update-inventory:
    echo "all:" > {{inventory_file}}
    echo "  vars:" >> {{inventory_file}}
    echo "    ansible_user: root" >> {{inventory_file}}
    echo "  hosts:" >> {{inventory_file}}
    for container in {{containers}}; do \
        ip=$(docker inspect -f '{{"{{"}}range.NetworkSettings.Networks{{"}}"}}{{"{{"}}.IPAddress{{"}}"}}{{"{{"}}end{{"}}"}}' $container); \
        echo "    $container:" >> {{inventory_file}}; \
        echo "      ansible_host: $ip" >> {{inventory_file}}; \
    done

# Create an project specific SSH configuration
update-ssh-config :
    touch {{  ssh_config  }}
    for container in {{containers}}; do \
        ip=$(docker inspect -f '{{"{{"}}range.NetworkSettings.Networks{{"}}"}}{{"{{"}}.IPAddress{{"}}"}}{{"{{"}}end{{"}}"}}' $container); \
        echo "Host $container" >> {{ ssh_config }}; \
        echo "    Hostname $ip" >> {{ ssh_config }}; \
        echo "    User root" >> {{ ssh_config }}; \
        echo "    IdentityFile {{ ssh_key }}" >> {{ ssh_config }}; \
        echo "    StrictHostKeyChecking no" >> {{ ssh_config }}; \
        echo ""  >> {{ ssh_config }}; \
    done

# interactively login to one node
ssh node:
    @ssh -F {{  ssh_config  }} {{ node}}

# Complete setup rule
setup:
    just generate-ssh-keys
    just build-image
    just start-containers
    just update-inventory

# Test setup
test-setup:
    ansible all -m ping

# Run update playbook
os-update:
    ansible-playbook all os-update.yaml

# Stop containers
shutdown:
    for container in {{containers}}; do \
        docker stop $container; \
    done

# Remove containers
cleanup:
    docker container prune

# Stop and remove containers, remove generated files
destroy:
    just shutdown
    just cleanup
    rm id_ed25519 id_ed25519.pub ssh_conf inventory.yaml
