bool IsBean( CItemInventory@ pItem )
{
	return ( pItem.m_szItemGroup == "ab-beans" && pItem.pev.model == "models/ragemap2018/adamr/kidney-bean.mdl" );
}

void RemoveBeansFromInventory( CBasePlayer@ pPlayer )
{
	InventoryList@ pInventory = pPlayer.get_m_pInventory();
	while( pInventory !is null && pInventory.hItem )
	{
		CItemInventory@ pItem = cast<CItemInventory>( pInventory.hItem.GetEntity() );
		if ( IsBean( pItem ) )
			g_EntityFuncs.Remove( pItem );

		@pInventory = pInventory.pNext;
	}
}

void BeanRecover( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float flValue )
{
	if( pActivator is null || !pActivator.IsPlayer() )
		return;

	CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );
	if( !pPlayer.IsAlive() )
		return;

	int iRecovered = 0;

	InventoryList@ pInventory = pPlayer.get_m_pInventory();
	while( pInventory !is null && pInventory.hItem )
	{
		CItemInventory@ pItem = cast<CItemInventory>( pInventory.hItem.GetEntity() );
		if ( !IsBean( pItem ) )
		{
			@pInventory = pInventory.pNext;
			continue;
		}

		g_EntityFuncs.FireTargets( "ab-bean_score", pPlayer, pCaller, USE_ON, 0 );
		g_EntityFuncs.FireTargets( pItem.m_szTriggerOnUseSelf, pPlayer, pCaller, USE_ON, 0 );

		iRecovered++;
		@pInventory = pInventory.pNext;
	}

	if( iRecovered >= 1 )
	{
		string szMsg;
		switch( iRecovered )
		{
			case 1:		snprintf( szMsg, "You recovered a bean. Nice." );					break;
			case 2:		snprintf( szMsg, "You recovered %1 beans. Cool.", iRecovered );		break;
			case 3:		snprintf( szMsg, "You recovered %1 beans. Splendid!", iRecovered );	break;
			default:	snprintf( szMsg, "You recovered %1 beans.\n\nYou must be a cheating fucko to have done that.\naeiou wanker.", iRecovered );
		}

		CBaseEntity@ pMsg = g_EntityFuncs.FindEntityByTargetname( null, "ab-bean_recovered_msg" );
		if( pMsg !is null && pMsg.GetClassname() == "game_text" )
			pMsg.pev.message = szMsg;
		else
			pMsg.pev.message = "The beans you were carrying have been recovered.";
		g_EntityFuncs.FireTargets( "ab-bean_recovered_msg", pPlayer, pCaller, USE_ON, 0 );
	}

	RemoveBeansFromInventory( pPlayer );
}
