//format: #include "AFBaseExpansions/<expansionfilename>"
//example: #inclue "AFBaseExpansions/BasicExpansion"
#include "AFBaseExpansions/AF2Player"
#include "AFBaseExpansions/AF2Entity"
#include "AFBaseExpansions/AF2Fun"
#include "AFBaseExpansions/AF2EKI"
#include "AFBaseExpansions/AF2Menu"
#include "AFBaseExpansions/pets"
#include "AFBaseExpansions/hats"
//#include "AFBaseExpansions/hookmod"

void AFBaseCallExpansions()
{
	//add calls below this line
	//format: <expansionname>_Call();
	//example: BasicExpansion_Call();
	AF2Player_Call(); // adminfuckery 2 player commands
	AF2Entity_Call(); // adminfuckery 2 entity commands
	AF2Fun_Call(); // adminfuckery 2 fun commands
	AF2Menu_Call(); // adminfuckery 2 menu system
        Hats_Call();
//        HookMod_Call();
                Hats_Call();
                Pets_Call();
}
