# Mesh.OK

Text chat between two Android devices via wifi-direct. Written in flutter using the flutter_p2p_connection plugin. Made for research purposes.

## TODO

Problems that need fixing:
1) Errors are not handled at all.
2) It is not clear how to add a third peer to the group.
3) Disconnecting from the group does not work, you have to delete the entire group.
4) It is not clear how to accept incoming connection requests from another group if the current group is active.
PS
Probably, the flutter_p2p_connection plugin is not suitable for use in production, and you need to use the native Android API.
