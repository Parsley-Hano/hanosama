namespace BuyMenu
{

final class BuyableItem
{
	private string m_szDescription;
	private string m_szEntityName;
	private uint m_uiCost = 0;
	private bool m_bAllPlayers = true;
	
	string Description
	{
		get const { return m_szDescription; }
		set { m_szDescription = value; }
	}
	
	string EntityName
	{
		get const { return m_szEntityName; }
		set { m_szEntityName = value; }
	}
	
	uint Cost
	{
		get const { return m_uiCost; }
		set { m_uiCost = value; }
	}
	
	bool AllPlayers
	{
		get const { return m_bAllPlayers; }
		set { m_bAllPlayers = value; }
	}
	
	BuyableItem( const string& in szDescription, const string& in szEntityName, const uint uiCost, const bool bAllPlayers = true )
	{
		m_szDescription = szDescription;
		m_szEntityName = szEntityName;
		m_uiCost = uiCost;
		m_bAllPlayers = bAllPlayers;
	}
	
	void Buy( CBasePlayer@ pPlayer = null )
	{
		if( !m_bAllPlayers && pPlayer is null )
			return;
			
		if( m_bAllPlayers )
		{
			for( int iPlayer = 1; iPlayer <= g_Engine.maxClients; ++iPlayer )
			{
				CBasePlayer@ pPl = g_PlayerFuncs.FindPlayerByIndex( iPlayer );
				
				if( pPl !is null )
				{
					GiveItem( pPl );
				}
			}
		}
		else
		{
			GiveItem( pPlayer );
		}
	}
	
	private void GiveItem( CBasePlayer@ pPlayer ) const
	{
		const uint uiMoney = uint( pPlayer.pev.frags );
		
		g_Game.AlertMessage( at_console, "frags: %1, money: %2\n", pPlayer.pev.frags, uiMoney );
		
		if( pPlayer.pev.frags <= 0 )
		{
			g_PlayerFuncs.ClientPrint(pPlayer,HUD_PRINTTALK,"Not enough money(frags) - Cost: " + m_uiCost + "\n");
			return;
		}
		
		if( uiMoney >= m_uiCost )
		{
			const uint uiLeft = uiMoney - m_uiCost;
			
			pPlayer.pev.frags -= m_uiCost;
			
			pPlayer.GiveNamedItem( m_szEntityName );
		}
		else
		{
			g_PlayerFuncs.ClientPrint(pPlayer,HUD_PRINTTALK,"Not enough money(frags) - Cost: " + m_uiCost + "\n");
			return;
		}
	}
}

final class BuyMenu
{
	array<BuyableItem@> m_Items;
	
	private CTextMenu@ m_pMenu = null;

	void RemoveItems()
	{
		if( m_Items !is null )
		{
			m_Items.removeRange( 0, m_Items.length() );
		}
	}
	
	void AddItem( BuyableItem@ pItem )
	{
		if( pItem is null )
			return;
			
		if( m_Items.findByRef( @pItem ) != -1 )
			return;
			
		m_Items.insertLast( pItem );
		
		if( m_pMenu !is null )
			@m_pMenu = null;
	}
	
	void Show( CBasePlayer@ pPlayer = null )
	{
		if( m_pMenu is null )
			CreateMenu();
			
		if( pPlayer !is null )
			m_pMenu.Open( 0, 0, pPlayer );
		else
			m_pMenu.Open( 0, 0 );
	}
	
	private void CreateMenu()
	{
		@m_pMenu = CTextMenu( TextMenuPlayerSlotCallback( this.Callback ) );
		
		m_pMenu.SetTitle( "Buy an item:" );
		
		for( uint uiIndex = 0; uiIndex < m_Items.length(); ++uiIndex )
		{
			BuyableItem@ pItem = m_Items[ uiIndex ];
			
			m_pMenu.AddItem( pItem.Description, any( @pItem ) );
		}
		
		m_pMenu.Register();
	}
	
	private void Callback( CTextMenu@ menu, CBasePlayer@ pPlayer, int iSlot, const CTextMenuItem@ pItem )
	{
		if( pItem !is null )
		{
			BuyableItem@ pBuyItem = null;
			
			pItem.m_pUserData.retrieve( @pBuyItem );
			
			if( pBuyItem !is null )
			{
				pBuyItem.Buy( pPlayer );
			}
		}
	}
}
}