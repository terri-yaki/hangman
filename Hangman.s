.global main



bytecopy:

    push {r3-r10,lr}
    bytecopyloop:
        ldrb r3, [r0], #1 //load byte
        strb r3, [r1], #1 //store byte
        sub r2, r2, #1  //reduce counter
        cmp r2, #0      //check counter
        bgt bytecopyloop    //loop
    pop {r3-r10,lr}
bx lr

getlength:
    push {r2-r10,lr}        
    mov r3, #0              
    getlengthloop:             
        ldrb r1, [r0], #1           //load byte
        cmp r1, #0          
        beq getlengthend            //if the byte is null end
        cmp r1, #32                 //if the byte is a space
        beq getlengthend            // end
        add r3, r3, #1              //add counter
        bne getlengthloop           //continue looping
    getlengthend:
        mov r1, r3                  //move r3 to r0 as a return value
        pop {r2-r10,lr}             //pop and branch back
bx lr

invalidcharacter:
    ldr r1, =input          //print invalid character message
    mov r0, #0
    strb r0, [r1]           //wipes input
    ldr r0, =invalidcharactermessage
    bl puts
    b getinput

guess:
//check if the guess exists in guessed
    ldr r0, =input
    ldr r0, [r0]            //load the guess 
    ldr r1, =guessed        //load address to guessed
    mov r3, #0              //counter            
    guessloop:
        ldrb r2, [r1, r3]   //gets the next byte
        cmp r2, #0          //check if null
        beq addguessed
        add r3, r3, #1      //increment counter
        cmp r2, r0          //compare 
        bne guessloop       //not equal continue
        beq foundguessed    //equal branch

        
    addguessed:
    strb r0, [r1, r3]       //add guess to guessed
    b replaceword


    foundguessed:
    //print error message 
    ldr r0, =duplicatecharacter
    bl puts
    b getinput


replaceword:

    ldr r0, =word           //load word address
    mov r8, r0              
    bl getlength            //get length of the word
    mov r7, r1              //store result
    mov r0, r8              
    ldr r1, =input          //load input address 
    ldr r1, [r1]            //load the value of input
    mov r2, #0              //loop counter
    mov r4, #0              //counter for multiple finds
    replacewordloop:
        ldrb r3, [r0, r2]   //load byte
        cmp r1, r3          //compare 
        bleq replace        //if equal replace
        moveq r4, #1        //make r4 1 if equal
        cmp r2, r7          //check if checked all characters
        add r2, r2, #1      //increase counter
        bne replacewordloop //counter not equal
        cmp r4, #0          //check r4
        beq addfailure      //add failure if no finds
        b display           //if not then the character is a valid guess without penalty


    replace:
    push {r3, lr}
        ldr r3, =removedword  //load address to replacdword 
        strb r1, [r3,r2]    //store guessed charatcer
    pop {r3, lr}
    bx lr


    addfailure:

        ldr r0, =failures   //load failures 
        ldr r1, [r0]        //load the value 
        add r1, r1, #1      //add one to the value
        strb r1, [r0]       //store new value
        b display       


display:

    ldr r0, =wordformat
    ldr r1, =removedword
    bl printf               //print removed word

    ldr r0, =guessedformat
    ldr r1, =guessed
    bl printf               //print guessed


    ldr r0, =failures       //load failures 
    ldr r2, [r0]            //load failures data 
    ldr r0, =hangman1       //load hagman1
    mov r4, #70             //length in bytes
    mul r3, r2, r4          //multiply by failure count
    add r0, r0, r3          //add to get address
    bl puts                 //print


    ldr r0, =failures       //get the number of failures again
    ldr r0, [r0]            
    cmp r0, #6              //equal to 6 loss
    beq lose
    
    //check if removedword and word are the same
    ldr r0, =removedword
    ldr r1, =word
    //check if r0 and r1 are the same
    mov r4, #1              
    checkequalloop:
        ldrb r2, [r0], #1           //load 1 byte
        ldrb r3, [r1], #1           
        cmp r2, #0                  //compare with null
        beq checkequalend           //end if null
        cmp r2, r3                     //compare 
        bne checkequalnotend        //if not stop
        beq checkequalloop          

    checkequalnotend:               
    mov r4, #0             
    bl checkequalend                
    checkequalend:
    mov r0, r4             

    cmp r0, #1              //if r0=1, equal and win
    beq win                 //win 
    bne getinput            //continue

win:
//congrats! prints win message and goes to end state
ldr r0, =winmessage
ldr r1, =word
bl printf
b end

lose:
//better luck next time :c prints lose message and goes to end state
ldr r0, =losemessage
ldr r1, =word
bl printf
b end


end:

    ldr r0, =endmessage         
    bl puts                 //print the ending message

    mov r0, #0              //read input
    ldr r1, =input          
    mov r2, #1              
    mov r7, #3              
    svc #0                  

    ldrb r2, [r1]           //load input

    cmp r2, #48             //compare to asccii 0 #48
    beq exit                //if equal exit
    bne main                //else start new game

exit:
    ldr r0, =exitmessage            
    bl puts                     //print exit message
    mov r7, #1                  //exits    
    svc 0


getinput:

    ldr r0, =inputmessage       //prints input message
    bl printf
    mov r0, #0
    ldr r0, =inputformat
    ldr r1, =input
    bl scanf                //reads input
    ldr r1, =input          
    ldrb r2, [r1]           //gets input character
    cmp r2, #48             //check if 0
    beq exit                //if so exit
    cmp r2, #65             //check if under valid ascii range
    blt invalidcharacter         //if so show error
    cmp r2, #122            //check if over valid ascii range
    bgt invalidcharacter         //if so error
    cmp r2, #97             //check if uppercase

    blt guess          //if so check guess
    sub r2, r2, #32         //(if lowercase) convert to uppercase
    strb r2, [r1]           //store character
    bl guess           //check guess


main:

    ldr r0, =failures       // set failures to 0
    mov r1, #0
    strb r1, [r0]           


    ldr r0, =guessed   // remove guessed charracters
    mov r1, #28    
    mov r2, #0              //counter
    mov r3, #0              //null "byte"
    wipememoryloop:
        add r2, r2, #1      //incriment counter
        strb r3, [r0], #1   //store a null byte in current r0 pos
        cmp r2, r1          //compare the counter and limit (r1)
        bne wipememoryloop         //loop until they are equal (wipe complete)

    ldr r0, =welcome            //print welcome message
    bl puts

                                //get a random word

    mov r0, #0
    bl time
    bl srand
    bl rand
    and r0, r0, #0x0F
    // here is to do modulo operation r0 % 9
    mov r7, #9                  // upper limit is 9 stored in r7
    udiv r5, r0, r7             // divides an unsigned value
    mul r8, r5, r7              // need for computing reminder
    sub r1, r0, r8              // the mod (reminder)

    ldr r0, =message1           // store address of message1 into r0
    mov r4, #19                 // each message length is 18, +1 for null    
    mul r5, r1, r4              // multiply the random number with the message length
    add r0, r0, r5              // r0 is now pointing at the correct address
    //copy into memory
    mov r2, r4
    ldr r1, =word
    bl bytecopy
    // replace word with _
    ldr r0, =word
    bl getlength
    ldr r0, =removedword //address of word
    ldr r2, =underscore //address of underscore
    ldr r2, [r2] //load into register
    mov r4, #0 //i
    removewordloop:
        strb r2, [r0, r4]
        add r4, r4, #1
        cmp r4, r1
        bne removewordloop


    b getinput              //start game

.data
.align 2
input: .space 8                 //store uinput
failures: .space 8              //store number of failure
guessed: .space 216             //byte for every letter in alphabet
word: .space 200                //store random word
removedword: .space 200           //word replaced with _

.align 2
welcome: .asciz "Welcome to the hangman game made by HoYu Lee\nYou have 6 wrong or duplicated guesses to guess the word\n press 0 to exit."
wordformat: .asciz "word: %s\n"
invalidcharactermessage: .asciz "invalid character"
duplicatecharacter: .asciz "duplicate character"
guessedformat: .asciz "guessed characters: %s\n"
inputmessage: .asciz "enter next character or press 0 to quit."
winmessage: .asciz "You have won\nThe word was %s\n"
losemessage: .asciz "You have lost\nThe word was %s\n"
endmessage: .asciz "press 0 to exist. press other key to start another game"
exitmessage: .asciz "goodbye"
underscore: .asciz "_"
inputformat: .asciz "\n%c"
// words and hangman
.align 2
message1: .asciz "TESTS             "
message2: .asciz "CHALLENGE         "
message3: .asciz "UNIVERSITY        "
message4: .asciz "STUDENTS          "
message5: .asciz "BALANCE           "
message6: .asciz "FEEDBACK          "
message7: .asciz "BINARY            "
message8: .asciz "INTELLIGENCE      "
message9: .asciz "CARTOGRAPHERS     "
message10: .asciz "CHARACTERISTICALLY"
.align 2 
hangman1: .asciz "  -----  \n  |   |  \n      |  \n      |  \n      |  \n      |  \n---------"
hangman2: .asciz "  -----  \n  |   |  \n  O   |  \n      |  \n      |  \n      |  \n---------"
hangman3: .asciz "  -----  \n  |   |  \n  O   |  \n  |   |  \n      |  \n      |  \n---------"
hangman4: .asciz "  -----  \n  |   |  \n  O   |  \n /|   |  \n      |  \n      |  \n---------"
hangman5: .asciz "  -----  \n  |   |  \n  O   |  \n /|\  |  \n      |  \n      |  \n---------"
hangman6: .asciz "  -----  \n  |   |  \n  O   |  \n /|\  |  \n /    |  \n      |  \n---------"
hangman7: .asciz "  -----  \n  |   |  \n  O   |  \n /|\  |  \n /\   |  \n      |  \n---------"
