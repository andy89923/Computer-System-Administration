<! --- /usr/local/www/sahw4/dns --->
<html>
<body>

<?php
    $uri = $_SERVER['REQUEST_URI'];

    # Display username
    if (strpos($uri, "display")) {
        $str = array_pop(explode('/', $uri));
        echo "Display: $str";
        exit();
    }

    # Calculate A + B
    if (strpos($uri, "calculate")) {
        $str = array_pop(explode('/', $uri));
        $num = explode('+', $str);
        $ans = (int)$num[0] + (int)$num[1];
        echo "Result: $ans";
        exit();
    }
    
    # Redirect to Youtube
    $vid = $_GET['vid'];
    $tim = $_GET['time'];

    if (! $vid) {
        echo "<h2>App route enabled</h2>";
        exit();
    }
    if (! $tim) {
        header("Location: https://youtu.be/$vid");
        exit();
    }

    header("Location: https://youtu.be/$vid?t=$tim");
    exit();
?>

</body>
</html>