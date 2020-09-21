#include "BulletEjection"
#include "BuyMenu"
#include "weapon_ak47"
#include "weapon_m4a1"
#include "weapon_aug"
#include "weapon_sg552"
#include "weapon_famas"
#include "weapon_galil"
#include "weapon_csm249"
#include "weapon_awp"
#include "weapon_sg550"
#include "weapon_g3sg1"
#include "weapon_scout"
#include "weapon_csknife"
#include "weapon_hegrenade"
#include "weapon_xm1014"
#include "weapon_m3"
#include "weapon_ump45"
#include "weapon_tmp"
#include "weapon_mac10"
#include "weapon_p90"
#include "weapon_mp5navy"
#include "weapon_csdeagle"
#include "weapon_csglock18"
#include "weapon_fiveseven"
#include "weapon_dualelites"
#include "weapon_p228"
#include "weapon_usp"
#include "weapon_c4"
#include "cs16ammo"

BuyMenu::BuyMenu g_BuyMenu;

void RegisterCS16()
{
	g_BuyMenu.RemoveItems();
	RegisterHEGRENADE();
	RegisterCSDeagle();
	RegisterFIVESEVEN();
	RegisterGLOCK18();
	RegisterUSP();
	RegisterP228();
	RegisterELITES();
	RegisterMP5Navy();
	RegisterP90();
	RegisterUMP45();
	RegisterTMP();
	RegisterMAC10();
	RegisterAK47();
	RegisterM4A1();
	RegisterAUG();
	RegisterM3Shotty();
	RegisterXM1014Shotty();
	RegisterAWP();
	RegisterSG552();
	RegisterCSM249();
	RegisterFAMAS();
	RegisterGALIL();
	RegisterSG550();
	RegisterG3SG1();
	RegisterCSKNIFE();
	RegisterSCOUT();
	RegisterC4();
	RegisterCSAmmo();
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<7> Ammo 556 Nato", "ammo_cs_556", 7 ,false ) );	// false = personally , true = globally
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<8> Ammo 762 Nato", "ammo_cs_762", 8 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<4> Ammo 9mm Para", "ammo_cs_9mm", 4 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<5> Ammo FN 57", "ammo_cs_fn57", 5 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<7> Ammo 50 Ae", "ammo_cs_50ae", 7 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<3> Ammo 45 Acp", "ammo_cs_45acp", 3 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<2> Ammo 357 Sig", "ammo_cs_357sig", 2 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<6> Ammo 12 Gauge", "ammo_cs_buckshot", 6 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<15> Ammo 338 Lapua", "ammo_cs_338lapua", 15 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<12> Ammo 556 Nato Heavy", "ammo_cs_556box", 12 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<5> CS Knife", "weapon_csknife", 5 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<9> USP", "weapon_usp", 9 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<8> Glock 18", "weapon_csglock18", 8 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<6> P-228", "weapon_p228", 6 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<8> Five Seven", "weapon_fiveseven", 8 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<14> Dual Elites", "weapon_dualelites", 14 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<18> Desert Eagle", "weapon_csdeagle", 18 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<20> HE Grenade", "weapon_hegrenade", 20 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<35> C4", "weapon_c4", 35 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<55> M3 Super", "weapon_m3", 55 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<50> XM-1014", "weapon_xm1014", 50 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<25> TMP", "weapon_tmp", 25 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<21> Mac-10", "weapon_mac10", 21 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<30> MP5 Navy", "weapon_mp5navy", 30 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<24> Ump-45", "weapon_ump45", 24 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<45> P-90", "weapon_p90", 45 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<50> Galil", "weapon_galil", 50 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<55> Famas", "weapon_famas", 55 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<60> M4a1", "weapon_m4a1", 60 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<65> AK-47", "weapon_ak47", 65 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<70> AUG", "weapon_aug", 70 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<70> SG-552", "weapon_sg552", 70 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<55> Scout", "weapon_scout", 55 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<95> AWP", "weapon_awp", 95 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<85> G3-SG1", "weapon_g3sg1", 85 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<78> SG-550", "weapon_sg550", 78 ,false ) );
	g_BuyMenu.AddItem( BuyMenu::BuyableItem( "<75> M249", "weapon_csm249", 75 ,false ) );
	g_Hooks.RegisterHook( Hooks::Player::ClientSay, @ClientSay );
}

HookReturnCode ClientSay( SayParameters@ pParams )
{
	CBasePlayer@ pPlayer = pParams.GetPlayer();
	const CCommand@ args = pParams.GetArguments();
	
	if( args.ArgC() == 1 && args.Arg(0) == "buy" || args.Arg(0) == "/buy" )
	{
        pParams.ShouldHide = true;
		g_BuyMenu.Show( pPlayer );
	}
	else if( args.ArgC() == 2 && args.Arg(0) == "buy" || args.Arg(0) == "/buy" )
	{
		pParams.ShouldHide = true;
		bool bItemFound = false;
		string szItemName;
		uint uiCost;

		if( g_BuyMenu.m_Items.length() > 0 )
		{
			for( uint i = 0; i < g_BuyMenu.m_Items.length(); i++ )
			{
				if( "weapon_" + args.Arg(1) == g_BuyMenu.m_Items[i].EntityName || "ammo_" + args.Arg(1) == g_BuyMenu.m_Items[i].EntityName )
				{
					bItemFound = true;
					szItemName = g_BuyMenu.m_Items[i].EntityName;
					uiCost = g_BuyMenu.m_Items[i].Cost;
					break;
				}
				else
					bItemFound = false;
			}

			if( bItemFound )
			{
				if(  pPlayer.pev.frags <= 0 )
				{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money(frags) - Cost: " + uiCost + "\n" );
				}
				else 
					if( uint(pPlayer.pev.frags) >= uiCost )
					{
						pPlayer.pev.frags -= uiCost;
						pPlayer.GiveNamedItem( szItemName );
					}
					else
					g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Not enough money(frags) - Cost: " + uiCost + "\n" );
			}
			else
			{
				g_PlayerFuncs.ClientPrint( pPlayer, HUD_PRINTTALK, "Invalid item: " + args.Arg(1) + "\n" );
			}
		}
	}
	return HOOK_CONTINUE;
}