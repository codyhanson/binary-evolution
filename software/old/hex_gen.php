/usr/bin/php

<?php
$cnt = 0;

for($i = 0; $i < 250; $i++) {
	for($j = 0; $j < 256; $j++) {
		printf("%6d", $cnt);
		$cnt++;
	}
	echo "\n";
}

?>
