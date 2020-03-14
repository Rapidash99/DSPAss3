function f = my_filter(name, method)
    tic()
    if (method == "convol") then
        f = convol(IRC_resized, record)
    else
        f = ifft(fft(IRC_resized) .* fft(record))
    end
    time = toc()
    
    mprintf('filtering with %s by %s: %f seconds\n', name, method, time)
//    playsnd(f)
//    sleep(5000)
    savewave("data_out/" + name + " filtered by " + method + ".wav", f, 44100)
endfunction

IRC = loadwave('data/IRC.wav')
IRC_size = size(IRC, "c")
if (size(IRC) > 1) then
    IRC = IRC(1, :)
end

for name = list("drums", "speech", "violin", "voice", "Violin_Viola_Cello_Bass")
    record = loadwave("data/" + name + ".wav")
    if (size(record) > 1) then
        record = record(1, :)
    end
    
    n = max(IRC_size, size(record, "c"))
    IRC_resized = resize_matrix(IRC, -1, 2^(nextpow2(n) + 1))
    record = resize_matrix(record, -1, 2^(nextpow2(n) + 1))
    
    f = my_filter(name, "our algorithm")
    f = my_filter(name, "convol")
end

function [out, d_out] = my_iir(x, n, D, a, b)
    d_out=[0,D(1:size(D, 'c')-1)]
    d_out(1)=x(n) - a(1)*d_out(2) - a(2)*d_out(3)
    out = b(1)*d_out(1) + b(2)*d_out(2) + b(3)*d_out(3)
endfunction

function output = supafiltar(y, a, b)
    D = zeros(1, 3)
    output = zeros(1, size(y, 'c'))
    for n=1:size(y, 'c')
        [out, d_out] = my_iir(y, n, D, a, b)
        D = d_out
        output(n) = out
    end
endfunction

violin = loadwave("data/Violin_Viola_Cello_Bass.wav")

//lowpass
a =  [-1.9733442497812987, 0.9736948719763]
b =  [0.00008765554875401547, 0.00017531109750803094, 0.00008765554875401547]

savewave("data_out/Violin_Viola_Cello_Bass_out.wav", supafiltar(violin, a, b), 44100)

//highpass
a =  [-0.3769782747249014, -0.19680764477614976]
b =  [0.40495734254626874, -0.8099146850925375, 0.4049573425462687]

savewave("data_out/Violin_Viola_Cello_Bass_highpass_out.wav", supafiltar(violin, a, b), 44100);
