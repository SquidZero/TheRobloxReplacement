using Godot;
using System;
using System.Linq;

public partial class MultiplayerManager : Node
{
    PackedScene player_character_packed =(PackedScene) ResourceLoader.Load("res://player.tscn");
	[Export] public Button Host;
	[Export] public Button Join;
	[Export] Resource scene = ResourceLoader.Load("res://test.tscn");
	bool button_pressed = false;
	public string player_name;
    public int port = 4242;
    public string address = "localhost";
	long[] connected_peer_ids = {};
    Node[] players = {};
	ENetMultiplayerPeer multiplayerPeer = new();
	const int PORT = 4242;
	const string ADDRESS = "localhost";

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
        Host ??=(Button)GetNode("Control/Host");
        Join ??=(Button)GetNode("Control/Join");
		Host.Pressed += () => on_host_pressed();
		Join.Pressed += () => on_joined_pressed();
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}

    private void on_host_pressed()
    {
        button_pressed = true;
        GetNode("Control/Label").Set("text", "Server");
        GetNode("Control").Set("visible", false);
        multiplayerPeer.CreateServer(port);
        Multiplayer.MultiplayerPeer = multiplayerPeer;

        AddPlayerCharacter(1);

        multiplayerPeer.PeerConnected += async (new_peerid) => {
            await ToSignal(GetTree().CreateTimer(1), "timeout");

            GD.Print("timer ended");

            Rpc("AddNewlyConnectedPlayerCharacter", (int)new_peerid);
            RpcId(new_peerid, "AddPreviouslyConnectedPlayerCharacters",
                connected_peer_ids);
            AddPlayerCharacter(new_peerid);
        };

        }

    private void on_joined_pressed()
    {
        button_pressed = true;
        GetNode("Control/Label").Set("text", "Client");
        GetNode("Control").Set("tisible", false);
        multiplayerPeer.CreateClient(address, port);
        Multiplayer.MultiplayerPeer = multiplayerPeer;

    }

    [Rpc] public void AddNewlyConnectedPlayerCharacter(int newPeerId) {
        AddPlayerCharacter(newPeerId);
    }

    public void AddPlayerCharacter(long peer_id)
    {
        connected_peer_ids.Append(peer_id);
        Node player_character = player_character_packed.Instantiate();
        players.Append(player_character);
        if (peer_id != 1 && players[0] != null)
            player_character.Set("position", new Vector3((float)players[0].Get("position.x"),
            ((int)players[0].Get("position.y")) + 10, (float)players[0].Get("position.z")));
        player_character.SetMultiplayerAuthority((int)peer_id);
        AddChild(player_character);
    }

    [Rpc] public void AddPreviouslyConnectedPlayerCharacters(long[] peer_ids)
    {
        foreach(var peer_id in peer_ids)
            AddPlayerCharacter(peer_id);
    }

}
