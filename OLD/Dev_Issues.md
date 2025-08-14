# SSHFS Mount Issues with Docker - Notes

## Problem
When running this Docker setup from an SSHFS-mounted directory, Docker Compose fails with:
```
error while creating mount source path '/path/to/sshfs/mount/...': mkdir /path/to/parent: file exists
```

## Root Cause
Docker tries to create parent directories for volume mounts, but SSHFS mount points behave differently than local filesystems, causing Docker to fail when it tries to mkdir on the mount point itself.

## Confirmed Working Solution
Move the project to a local (non-SSHFS) directory. Everything works perfectly from local storage.

## Potential Workarounds (Not Implemented)
If you must work from SSHFS in the future, consider:

1. **Use docker run instead of docker-compose** - Sometimes works when compose doesn't
2. **Restart Docker daemon** - Can clear mount cache: `sudo systemctl restart docker`
3. **Use absolute paths in volumes** - Replace `./notebooks` with `${PWD}/notebooks`
4. **Use bind mount syntax** - Explicit `type: bind` in docker-compose
5. **Run without volume mounts** - Use `docker cp` to move files in/out

## Decision
Rather than complicate the setup with SSHFS workarounds, the clean solution is to work from local directories. The Docker setup remains simple and maintainable.

## Reference
- Ubuntu 24.04 host
- Docker version 20.10+
- SSHFS mount via VirtualBox VM
- Issue encountered: December 2024