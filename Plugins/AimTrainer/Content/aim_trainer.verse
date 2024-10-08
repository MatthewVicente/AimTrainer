
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Verse.org/Random }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
aim_trainer := class(creative_device):

    @editable var Prop : creative_prop = creative_prop{}
    @editable var MinimumPositions : vector3 = vector3{}
    @editable var MaximumPositions : vector3 = vector3{}
    @editable var PropManipulator : prop_manipulator_device = prop_manipulator_device{}
    @editable var ScoreBillboard : billboard_device = billboard_device{}
    @editable var WeaponSpawner : item_spawner_device = item_spawner_device{}
    @editable var EndGameDevice : end_game_device = end_game_device{}
    @editable var WinScore : float = 50.0

    ScoreText<localizes>(ScoreMessage:string): message = "Score: {ScoreMessage}"

    var TimeStamp : float = 0.0
    var Score : float = 0.0

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        PropManipulator.DamagedEvent.Subscribe(OnPorpDamaged)
        WeaponSpawner.ItemPickedUpEvent.Subscribe(OnWeaponPickedUp)
        ScoreBillboard.SetText(ScoreText("Score: {Score}"))
        
    OnWeaponPickedUp(Agent : agent) : void=
        spawn:
            ShowNextTarget(3.0)

    OnPorpDamaged(Agent : agent) : void=
        PropManipulator.HideProps()
        UpdateScore()
        spawn:
            ShowNextTarget(1.0)

    UpdateScore() : void=
        CurrentTimestamp := GetSimulationElapsedTime()
        AttackSpeed := CurrentTimestamp - TimeStamp

        var EarnedPoints : float = 1.0

        if (AttackSpeed <= 1.0):
            set EarnedPoints = 10.0
        else if (AttackSpeed <= 2.0):
            set EarnedPoints = 5.0
        else if (AttackSpeed <= 3.0):
            set EarnedPoints = 3.0
        else if (AttackSpeed >= 5.0):
            set EarnedPoints = 0.0

        set Score += EarnedPoints
        ScoreBillboard.SetText(ScoreText("Score: {Score}"))

        if (Score >= WinScore):
            AllPlayers := GetPlayspace().GetPlayers()
            for (Player : AllPlayers):
                if (Agent := agent[Player]):
                    EndGameDevice.Activate(Agent)

    ShowNextTarget(Delay : float)<suspends> : void=
        Sleep(Delay)
        
        RandX := GetRandomFloat(MinimumPositions.X, MaximumPositions.X)
        RandY := GetRandomFloat(MinimumPositions.Y, MaximumPositions.Y)
        RandZ := GetRandomFloat(MinimumPositions.Z, MaximumPositions.Z)
        NewPosition := vector3{X := RandX, Y :=RandY, Z := RandZ}
        if (Prop.TeleportTo[NewPosition, Prop.GetTransform().Rotation]) {}
        PropManipulator.ShowProps()
        set TimeStamp = GetSimulationElapsedTime()