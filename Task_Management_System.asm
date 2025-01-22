   include 'emu8086.inc'
.model small
.stack 100h
.data

    newLine  db 10, 13, "$"

    m1 db 13, 10, "*********************************************$" 
    m2 db 13, 10, "**               Task Management          **$" 
    m3 db 13, 10, "**                    System              **$" 
    m4 db 13, 10, "*********************************************$"

    mmOption1     db 13, 10, "1. Add Task $"
    mmOption2       db 13, 10, "2. Delete Task $"
    mmOption3   db 13, 10, "3. Show All Task $"
    mmOption4  db 13, 10, "4. Exit Program $"
    mmChoice        db 13, 10, "Enter Your Choice: $"

    tskCount         db 0                    
    tskName         db 10 dup(30 dup('$'))     
    tskDesc        db 10 dup(30 dup('$'))     
    tskTime        db 10 dup(30 dup('$'))     

    askTaskName  db 10, 13, "Task Name: $"
    askTaskDesc db 10, 13, "Description: $"
    askTaskTime db 10, 13, "Time: $"

    deleteSuccessMsg db 10, 13, "Task deleted successfully!$"
    invalidSerialMsg db "Invalid Serial Number!$"
    noTaskDelMsg   db "No Tasks to Delete.$"
    noTaskShowMsg   db "No Tasks to Display.$"
    taskHeader   db "All Task List:$"
    
    tab              db "    ||    $"

    a1 db 13, 10, "**************************************************$" 
    lea dx, newLine
    int 21h

    d1 db 13, 10, "**************************************************$" 

    
    s1 db 13, 10, "**************************************************$" 

    
.code
main proc
    mov   ax, @data
    mov   ds, ax

    call  DisplayMainMenu
main endp

DisplayMainMenu proc

    mov ah, 9
    lea dx, m1
    int 21h
    lea dx, m2
    int 21h
    lea dx, m3
    int 21h
    lea dx, m4
    int 21h
    lea dx, newLine
    int 21h

    lea   dx, mmOption1
    int   21h

    lea   dx, mmOption2
    int   21h
    
    lea   dx, mmOption3
    int   21h

    lea   dx, mmOption4
    int   21h
    

    lea   dx, mmChoice
    int   21h

    mov   ah, 1
    int   21h

    cmp   al, '1'
    je    AddTask

    cmp   al, '2'
    je    DeleteTask
                     
    cmp   al, '3'
    je    ShowAllTask

    
    cmp   al, '4'
    je    ExitProgram

    jmp   DisplayMainMenu
DisplayMainMenu endp

AddTask proc
    mov   al, tskCount
    cmp   al, 10          
    jae   MaxTasks  

    mov ah, 9
    lea dx, a1
    int 21h
    ;lea dx, a2
    ;int 21h
    ;lea dx, a3
    ;int 21h

    TaskName:    
 
    mov   ah, 9
    lea   dx, newLine
    int   21h
   
    print 'Task Name: '

    ; Store name into Names array
    mov   si, offset tskName
    mov   bl, tskCount 
    mov   bh, 0
    mov   di, bx      
    
    mov   si, offset tskName     
    mov   bl, tskCount 
    mov   bh, 0         

    mov   ax, bx        
    mov   cx, 30       

    mul   cx           
   

    add   si, ax        
    call  GetInput      
    call  NL

    TaskDescription:   
    ; Prompt for Desc
    print 'Task Description: '

 
    mov   si, offset tskDesc
    mov   bl, tskCount   
    mov   bh, 0
    mov   di, bx          
    
    mov   si, offset tskDesc  
    mov   bl, tskCount         
    mov   bh, 0              

    mov   ax, bx        
    mov   cx, 30        

    mul   cx            

    add   si, ax        
    call  GetInput    
    call  NL
    
    TaskTime:   
    ; Prompt for task time

    print 'Task Time: '

    ; Store time into array
    mov   si, offset tskTime
    mov   bl, tskCount   
    mov   bh, 0
    mov   di, bx       
    
    mov   si, offset tskTime    
    mov   bl, tskCount            
    mov   bh, 0                   

    mov   ax, bx     
    mov   cx, 30  

    mul   cx        

    add   si, ax        
    call  GetInput      

    call  NL
    inc tskCount
    
    call NL
    print 'Task added successfully!'
    jmp   DisplayMainMenu

    MaxTasks:    
    ; Display message when max limit is reached
    mov   ah, 9
    lea   dx, newLine
    int   21h
    lea   dx, taskHeader
    int   21h
    jmp   DisplayMainMenu
AddTask endp


GetInput proc
    InputLoop:       
    mov   ah, 1         
    int   21h
    cmp   al, 13        
    je    DoneInput
    
    mov   [si], al      
    inc   si
    jmp   InputLoop

    DoneInput:       
    mov [si], '$'      
    ret
GetInput endp



DeleteTask proc
    mov   al, tskCount      ; Load the task count into al
    cmp   al, 0             ; Check if there are no tasks to delete
    je    NoTaskToDelete    ; Jump to NoTaskToDelete if no tasks

    mov ah, 9
    lea dx, d1              ; Display "Delete Task" header
    int 21h

    call NL 
    print "0. For the Mainmenu"
    call NL
    print "Enter Task Serial Number to Delete (1 to ", tskCount, "): " ; 

    mov   ah, 1
    int   21h               
    
    sub   al, '0'           ;
    cmp   al, 0             
    je    DisplayMainMenu

    cmp   al, tskCount      
    ja    InvalidSerial     

    mov   bl, al            
    dec   bl                

    lea   si, tskName       
    lea   di, tskDesc      
    lea   bp, tskTime      

    xor   cx, cx            
    mov   cl, tskCount   

    sub   cl, bl         

    ; Shift the data for each task (30 bytes per task)
    lea   si, tskName
    lea   di, tskDesc
    lea   bp, tskTime
    mov   ax, bx            ; Load the selected task index into ax
    mov   bx, 30            ; Size of one task data
    mul   bx                ; Multiply by the task size to calculate the offset
    add   si, ax            ; Set si to the starting point of the task to delete

    ; Shift loop
ShiftLoop:
    movsb                   ; Move byte from si to di (task name)
    movsb                   ; Move byte from si to di (task description)
    movsb                   ; Move byte from si to di (task time)

    add   si, 29            ; Skip the 29 bytes of the current task
    add   di, 29            ; Skip the 29 bytes of the current task
    loop  ShiftLoop         ; Repeat the loop for each task to shift

    ; Decrement the task count
    dec   tskCount

    call NL
    print 'Task deleted successfully!'
    call NL
    jmp   DisplayMainMenu

InvalidSerial:
    call NL
    print "Invalid Serial Number! Please try again."
    call NL
    jmp   DisplayMainMenu

NoTaskToDelete:
    mov   ah, 9
    lea   dx, newLine
    int   21h
    lea   dx, noTaskDelMsg
    int   21h
    jmp   DisplayMainMenu
DeleteTask endp



ShowAllTask proc
    mov   al, tskCount
    cmp   al, 0
    je    NoTasks

    mov ah, 9
    lea dx, s1
    int 21h
    ;lea dx, s2
    ;int 21h
    ;lea dx, s3
    ;int 21h
    lea dx, newLine
    int 21h
     

    ; Display header row
    lea dx, newLine
    int 21h
    
    print 'Serial-No.  ||    '
    
    print 'Name'
    lea   dx, tab
    int   21h
    

    print 'Description'
    lea   dx, tab
    int   21h
    
    print 'Time'
    lea   dx, newLine
    int   21h

    ; Display details
    xor   cx, cx          
    mov   cl, tskCount      
    xor   bp, bp          
    inc   bp              

    mov   si, offset tskName
    mov   bx, offset tskDesc
    mov   di, offset tskTime

    DisplayLoop: 
        
    ; Display serial number
    ; push  cx
    mov   ax, bp                 
    mov   dl, al               
    add   dl, '0'           
    mov   ah, 2                  
    int   21h 
    
    
    mov   dl, ' '          
    mov   ah, 2             
    int   21h               

    mov   dl, ' '           
    mov   ah, 2
    int   21h               

    mov   dl, ' '          
    mov   ah, 2
    int   21h
    
    mov   dl, ' '          
    mov   ah, 2             
    int   21h               

    mov   dl, ' '          
    mov   ah, 2
    int   21h               

    mov   dl, ' '          
    mov   ah, 2
    int   21h  
    
    mov   ah, 9
    lea   dx, tab                 
    int   21h


    mov   ah, 9
    lea   dx, [si]
    int   21h

    lea   dx, tab
    int   21h

    
    mov   ah, 9
    lea   dx, [bx]
    int   21h
    
    lea   dx, tab
    int   21h

    mov   ah, 9
    lea   dx, [di]
    int   21h
    
    lea   dx, newLine
    int   21h

    add   si, 30              
    add   bx, 30               
    add   di, 30                 
    inc   bp                   
    
    ; pop   cx
    loop  DisplayLoop

    jmp   DisplayMainMenu

    NoTasks:     
    mov   ah, 9
    lea   dx, newLine
    int   21h
    lea   dx, noTaskShowMsg
    int   21h
    jmp   DisplayMainMenu
ShowAllTask endp

NL proc     ; Newline Function
    mov   dl, 13
    mov   ah, 02h
    int   21h
    mov   dl, 10
    mov   ah, 02h
    int   21h
    ret     
NL endp


    ExitProgram:     
    mov   ah, 4Ch
    int   21h
end main
