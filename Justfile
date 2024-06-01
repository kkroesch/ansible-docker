
# Define variables
containers := "fedora-1 fedora-2"
ssh_key := "id_ed25519.pub"
image_name := "fedora_ssh"
inventory_file := "inventory.yaml"

# Rule to generate SSH keys
generate-ssh-keys:
    [ -f {{ssh_key}} ] || ssh-keygen -t ed25519 -f {{ssh_key}} -N ""

# Rule to build the Docker image
build-image:
    docker build -t {{image_name}} .

# Rule to create and start containers
start-containers:
    docker network create ansible_network || true
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

# Complete setup rule
setup:
    just generate-ssh-keys
    just build-image
    just start-containers
    just update-inventory

test-setup:
    ansible all -m ping

os-update:
    ansible-playbook all os-update.yaml