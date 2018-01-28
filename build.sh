cd game
rm Terraformer.love || :
zip -9 -r Terraformer.love .
mv Terraformer.love ../
cd ..
cp Terraformer.love TerraformerSrc.zip
cat love_windows/love.exe Terraformer.love > Terraformer.exe
rm -R terraformer
mkdir -p terraformer/
cd love_windows
cp ../Terraformer.exe SDL2.dll OpenAL32.dll license.txt love.dll lua51.dll mpg123.dll msvcp120.dll msvcr120.dll ../terraformer
cd ..
zip -9 -r Terraformer.zip terraformer/
