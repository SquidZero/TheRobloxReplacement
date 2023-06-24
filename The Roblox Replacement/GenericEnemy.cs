using Godot;
using static Godot.GD;
using System;

public partial class GenericEnemy : GenericRaycastTarget
{
	public int health = 100;


	public void Die() {
		Print("enemy died");
	}

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if(health <= 0) {
		//  Kill the Enemy.
			Die();
			QueueFree();
		}
	}
}
