package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func main() {
	pswds, _ := os.ReadFile("possible_pswds.txt")

	pswds_str := strings.Split(string(pswds), "\n")

	for pswd := range pswds_str {
		cmd := exec.Command("sh", "-c", fmt.Sprintf("echo '%s' | spike pk target_Sanyam-Asthana", pswd))

		output, _ := cmd.CombinedOutput()
		fmt.Println(string(output))

		if string(output) == "You have passed!" {
			fmt.Println("password is: ")
			fmt.Println(pswd)
		}
	}
}

