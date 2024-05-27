#start=led_display.exe#

.model small
.stack 100h  

.data
    kelimeler db "elma$", "armut$", "bilgi$", "kalem$", "tilki$", "bit$", "at$", "bal$", "mart$", "kutu$", "&"
    harfler db "elmautbigkr"
    input db 11,?,11 dup('$') 

.code
main:
    mov ax, @data                   
    mov ds, ax              
    
    ; 11 tane harfi ekrana yazdir
    mov si, offset harfler               ; harfler dizisinin baslangic adresini si'ye yukle
    mov cx, 11                           ; cx'e 11 ata (harf sayisi, dongu icin)  
    call harfleri_yazdir 
                 
    jmp oyun    
                      
harfleri_yazdir:
    mov dl, [si]                         ; si adresindeki harfi dl'e yukle
    mov ah, 02h                          ; yazdirma kesmesi cagir
    int 21h                              ; ekrana harf yazdir
    mov dx, ' '                          ; bosluk karakterini dl'e yukle
    int 21h                              ; ekrana bosluk yazdir
    inc si                               ; bir sonraki harfe gec
    dec cx                               ; cx'i azalt
    jnz harfleri_yazdir                  ; cx sifir degilse loop (jnz=jump if not zero)

oyun:
    call input_al
    call kelime_kontrol
     
    
puan_arttir:   
    in al, 199                           ; 199 portlu leddeki degeri al'ye al      
    inc al                               ; 1 arttir
    out 199, al                          ; lede yeni arttirilmis degeri geri yazdir

input_al:   
    mov ah, 02h                          ; her inputta alt satira inmek icin:    
    mov dl, 0Dh      
    int 21h          
    mov dl, 0Ah      
    int 21h          

    mov ah, 0Ah          
    lea dx, input
    int 21h              

kelime_kontrol proc  
    mov bx, offset kelimeler          ; kelimeler dizisinin baslangicç adresini bx'e yukle
    mov di, offset input + 2          ; input'un parametrelerden sonra gelen baslangic adresini di'ye yukle
    mov cx, offset kelimeler          ; kelimenin uzunlugunu tutacak register
    
    kelime_kac_harf:
        mov al, [bx]
        inc bx
        cmp al, '$'
        je register_duzenleme         ; kelime bittiyse sonraki adima gec
        jmp kelime_kac_harf
    
    register_duzenleme:
        push bx
        push cx
        pop bx
        pop cx
        jmp kelime_dongusu            ; registerlari yer degistirip donguye geciyoruz
        
    kelime_dongusu:
        mov al, [bx]                  ; kelimelerdeki bir harfi al
        mov dl, [di]                  ; input'taki bir harfi al
        
        cmp al, '$'                   ; kelimenin sonu geldiyse kelime_bulundumu'ya git
        je kelime_bulundumu   
        
        cmp al, '&'                   ; kelime listesi bittiyse oyuna geri don
        je oyun
        
        cmp al, dl                    ; harfleri karsilastir 
        jne sonraki_kelime            ; eger farkliysa sonraki kelimeye gecç
        inc bx                        ; kelimenin bir sonraki harfine gec
        inc di                        ; inputun bir sonraki harfine gecç
        jmp kelime_dongusu            ; donguye devam et
    sonraki_kelime:
        mov bx, cx                    ; bir sonraki kelimeden devam et
        mov di, offset input + 2      ; input'u resetle
        jmp kelime_kac_harf           ; kelimeler dizisinin sonraki kelimesine gec 
    
    kelime_bulundumu: 
        cmp dl, 13                    ; enter'in ASCII karsiligi 0d'dir yani 13tur
        je kelime_bulundu             ; eger kelime ile input ayni anda bittiyse dogru demektir
        jmp sonraki_kelime            ; ayni degillerse kelimeler dizisinin sonraki kelimesine gec
        
    kelime_bulundu: 
        call puan_arttir
        jmp oyun
kelime_kontrol endp

end main
