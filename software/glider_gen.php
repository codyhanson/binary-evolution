/usr/bin/php

<?php
for($i = 0; $i < 256; $i++) {

	for($j = 0; $j < 256; $j++) {
		if ($i == 8 ) {
			if ($j == 30 || $j == 31 || $j == 41 || $j == 42) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 9) {
			if ($j == 29 || $j == 31 || $j == 41 || $j == 42) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 10) {
			if ($j == 7 || $j == 8 || $j == 16 || $j == 17 || $j == 29 || $j == 30) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 11) {
			if ($j == 7 || $j == 8 || $j == 15 || $j == 17) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 12) {
			if ($j == 15 || $j == 16 || $j == 23 || $j == 24) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 13) {
			if ($j == 23 || $j == 25) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 14) {
			if ($j == 23) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 15) {
			if ($j == 42 || $j == 43) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 16) {
			if ($j == 42 || $j == 44) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 17) {
			if ($j == 42) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 20) {
			if ($j == 31 || $j == 32 || $j == 33) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 21) {
			if ($j == 31) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else if ($i == 22) {
			if ($j == 32) {
				echo "FF ";
			} else {
				echo "00 ";
			}
		} else {
			echo "00 ";
		}
	}
	echo "\n";
}

?>
