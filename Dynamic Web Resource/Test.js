var genderOptions = ['male', 'female'];
var random = Math.random();
var maleCount = 0;
var femaleCount = 0;
var randomIndex = Math.floor(random * genderOptions.length);
for (var i = 0; i < 100; i++) {
    var random = Math.random();
    var randomIndex = Math.floor(random * genderOptions.length);
    var randomGender = genderOptions[randomIndex];
    if (randomGender === 'male') {
        maleCount++;
    } else {
        femaleCount++;
    }
}
console.log("Male count:", maleCount);
console.log("Female count:", femaleCount);