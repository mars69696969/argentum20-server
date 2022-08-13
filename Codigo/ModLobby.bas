Attribute VB_Name = "ModLobby"

Type PlayerInLobby
    SummonedFrom As t_WorldPos
    IsSummoned As Boolean
    UserId As Integer
End Type

Type lobby
    MinLevel As Byte
    MaxLevel As Byte
    MaxPlayers As Integer
    MinPlayers As Integer
    EventStarted As Boolean
    Players() As PlayerInLobby
    SummonCoordinates As t_WorldPos
    RegisteredPlayers As Integer
    ClassFilter As Integer 'check for e_Class or <= 0 for no filter
End Type

Public ActiveLobby As lobby

Public Sub InitializeLobby(ByRef instance As lobby)
    instance.MinLevel = 1
    instance.MaxLevel = 47
    instance.MaxPlayers = 100
    instance.MinPlayers = 1
    instance.EventStarted = False
    instance.RegisteredPlayers = 0
End Sub

Public Sub SetMaxPlayers(ByRef instance As lobby, ByVal playerCount As Integer)
    instance.MaxPlayers = playerCount
    ReDim instance.Players(0 To playerCount)
End Sub

Public Sub SetMinPlayers(ByRef instance As lobby, ByVal playerCount As Integer)
    instance.MinPlayers = playerCount
End Sub

Public Sub SetMinLevel(ByRef instance As lobby, ByVal level As Byte)
    instance.MinLevel = level
End Sub

Public Sub SetMaxLevel(ByRef instance As lobby, ByVal level As Byte)
    instance.MaxLevel = level
End Sub

Public Sub SetClassFilter(ByRef instance As lobby, ByVal Class As Integer)
    instance.ClassFilter = Class
End Sub

Public Function AddPlayer(ByRef instance As lobby, ByVal UserIndex As Integer) As Boolean
On Error GoTo AddPlayer_Err
    With UserList(UserIndex)
        If .Stats.ELV < instance.MinLevel Or .Stats.ELV > instance.MaxLevel Then
            AddPlayer = False
            Exit Function
        End If
        If instance.RegisteredPlayers >= instance.MaxPlayers Then
            AddPlayer = False
            Exit Function
        End If
        If instance.ClassFilter > 0 And .clase <> instance.ClassFilter Then
            AddPlayer = False
            Exit Function
        End If
        instance.Players(instance.RegisteredPlayers).UserId = UserIndex
        instance.Players(instance.RegisteredPlayers).IsSummoned = False
        instance.RegisteredPlayers = instance.RegisteredPlayers + 1
        AddPlayer = True
    End With
    Exit Function
On Error GoTo AddPlayer_Err
102     Call TraceError(Err.Number, Err.Description, "ModLobby.AddPlayer_Err", Erl)

End Function

Public Sub summonPlayer(ByRef instance As lobby, ByVal user As Integer)
   On Error GoTo SummonPlayer_Err
        Dim UserIndex As Integer
        With instance.Players(user)
            UserIndex = .UserId
            If Not .IsSummoned Then
                .SummonedFrom = UserList(UserIndex).Pos
            End If
100         Call WarpToLegalPos(UserIndex, instance.SummonCoordinates.map, instance.SummonCoordinates.X, instance.SummonCoordinates.y, True, True)
            .IsSummoned = True
        End With
    Exit Sub
On Error GoTo SummonPlayer_Err
102     Call TraceError(Err.Number, Err.Description, "ModLobby.AddPlayer_Err", Erl)
End Sub

Public Sub ReturnPlayer(ByRef instance As lobby, ByVal user As Integer)
On Error GoTo ReturnPlayer_Err
    Dim UserIndex As Integer
    With instance.Players(user)
        UserIndex = .UserId
        If Not .IsSummoned Then
            Exit Sub
        End If
100         Call WarpToLegalPos(UserIndex, .SummonedFrom.map, .SummonedFrom.X, .SummonedFrom.y, True, True)
        .IsSummoned = False
    End With
    Exit Sub
On Error GoTo ReturnPlayer_Err
102     Call TraceError(Err.Number, Err.Description, "ModLobby.ReturnPlayer", Erl)
End Sub
