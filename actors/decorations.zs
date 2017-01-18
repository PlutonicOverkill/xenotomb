class Ship1 : Actor
{
	Default
	{
		Radius 128;
		Height 96;
		ProjectilePassHeight -16;
		+SOLID
	}
	
	States
	{
	Spawn:
		SHP1 A -1;
		Stop;
	}
}

class SteamSpawner : SwitchableDecoration
{
	Default
	{
		Height 2;
		Radius 1;
		Mass 0;
		+NoBlockMap
		+NoGravity
		+NoInteraction
		+ClientSideOnly
	}
	
	States
	{
	Spawn:
	Active:
		TNT1 A 0;
		TNT1 A 0 A_JumpIf(Args[0] == 1, "Down");
		TNT1 A 0 A_JumpIf(Args[0] > 1, "Forward");
		TNT1 A 0 A_JumpIf(Args[1] > 0, "UpBurst");
		TNT1 A 0 A_JumpIf(Args[3] > 0, 2);
		TNT1 A 0 A_PlaySound("Steam/Loop", CHAN_7, 1.0, looping: true);
		TNT1 A 1 A_SpawnItemEx("SteamParticle", 0, 0, 1, (0.1)*Random(0, 4), 0, (0.1)*Random(35, 40), Random(0, 360), 128);
		Loop;
	Down:
		TNT1 A 0 A_JumpIf(Args[1] > 0, "DownBurst");
		TNT1 A 0 A_JumpIf(Args[3] > 0, 2);
		TNT1 A 0 A_PlaySound("Steam/Loop", CHAN_7, 1.0, looping: true);
		TNT1 A 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(0, 4), 0, (-0.1)*Random(35, 40), Random(0, 360), 128);
		Loop;
	Forward:
		TNT1 A 0 A_JumpIf(Args[1] > 0, "ForwardBurst");
		TNT1 A 0 A_JumpIf(Args[3] > 0, 2);
		TNT1 A 0 A_PlaySound("Steam/Loop", CHAN_7, 1.0, looping: true);
		TNT1 A 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(35, 40), 0, (0.1)*Random(-5, 5), Random(-8, 8), 128);
		Loop;
	UpBurst:
		TNT1 A 1 A_Jump(Args[2]/16, 1);
		Loop;
		TNT1 A 0 A_JumpIf(Args[3] > 0, 2);
		TNT1 A 0 A_PlaySound("Steam/Fire", CHAN_7, 0);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 1, (0.1)*Random(0, 4), 0, (0.1)*Random(35, 40), Random(0, 360), 128);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 1, (0.1)*Random(0, 4), 0, (0.1)*Random(35, 40), Random(0, 360), 128);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 1, (0.1)*Random(0, 4), 0, (0.1)*Random(35, 40), Random(0, 360), 128);
		Loop;
	DownBurst:
		TNT1 A 1 A_Jump(Args[2]/16, 1);
		Loop;
		TNT1 A 0 A_JumpIf(Args[3] > 0, 2);
		TNT1 A 0 A_PlaySound("Steam/Fire", CHAN_7, 0);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(0, 4), 0, (-0.1)*Random(35, 40), Random(0, 360), 128);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(0, 4), 0, (-0.1)*Random(35, 40), Random(0, 360), 128);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(0, 4), 0, (-0.1)*Random(35, 40), Random(0, 360), 128);
		Loop;
	ForwardBurst:
		TNT1 A 1 A_Jump(Args[2]/16, 1);
		Loop;
		TNT1 A 0 A_JumpIf(Args[3] > 0, 2);
		TNT1 A 0 A_PlaySound("Steam/Fire", CHAN_7, 0);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(35, 40), 0, (0.1)*Random(-5, 5), Random(-8, 8), 128);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(35, 40), 0, (0.1)*Random(-5, 5), Random(-8, 8), 128);
		TNT1 AAAAAAAAAA 1 A_SpawnItemEx("SteamParticle", 0, 0, 0, (0.1)*Random(35, 40), 0, (0.1)*Random(-5, 5), Random(-8, 8), 128);
		Loop;
	Inactive:
		TNT1 A 1 A_StopSound(CHAN_7);
		TNT1 A 1;
		Goto Inactive + 1;
	}
}

class SteamParticle : Actor
{
	Default
	{
		Height 1;
		Radius 1;
		+Missile
		+NoGravity
		+NoBlockMap
		RenderStyle "Add";
		Scale 0.4;
		Alpha 0.65;
	}
	
	States
	{
	Spawn:
		STEM A 2 A_SetTranslucent(0.6, 1);
		STEM B 2 A_SetTranslucent(0.55, 1);
		STEM C 2 A_SetTranslucent(0.5, 1);
		STEM D 2 A_SetTranslucent(0.45, 1);
		STEM E 2 A_SetTranslucent(0.4, 1);
		STEM F 2 A_SetTranslucent(0.35, 1);
		STEM G 2 A_SetTranslucent(0.3, 1);
		STEM H 2 A_SetTranslucent(0.25, 1);
		STEM I 2 A_SetTranslucent(0.2, 1);
		STEM J 2 A_SetTranslucent(0.15, 1);
		STEM K 2 A_SetTranslucent(0.1, 1);
		STEM L 2 A_SetTranslucent(0.05, 1);
		Stop;
	}
}