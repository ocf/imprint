# OCF Wordpress

For development, the image can be built and added to Docker with the following command:
`nix build .#docker && docker tag $(docker load -q < result | grep --only-matching -e 'ocf-wordpress-core:.*$') ocf-wordpress-core:latest`

A docker compose file is provided as a testing environment. This should never be used in any production setting or exposed publicly. You can start this by running:
`docker compose up -d`

The admin user will be created with a random password, you can change this with:
`docker exec -u nobody:nobody [wp container] wp user update admin --user_pass=[password]]`
