"""Current game regression suite: bait-based star fishing."""
from pathlib import Path
import runpy
for suite in ('test_game_over.py','test_minimal_menu.py','test_difficulty.py','test_casting.py','test_rare_bites.py','test_worm_inventory.py','test_fishing.py'):
 runpy.run_path(str(Path(__file__).with_name(suite)),run_name='__main__')
