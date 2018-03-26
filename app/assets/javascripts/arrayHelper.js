if (!snowSense) var snowSense = {};


(function() {
  // Returns the index of the first occurrence of value within the array for the indicated property.
  // value is case-sensitive (if string)
  function findIndex(array, value, propertyName) {
      if (!array) return -1;
      for (var i = 0, len = array.length; i < len; i++) {
          if (array[i][propertyName] === value) return i;
      }
      return -1;
  }

  // Returns the item of the first occurrence of value within the array for the indicated property.
  // value is case-sensitive (if string)
  function findItemByValue(array, value, propertyName) {
    var index = findIndex(array, value, propertyName);
    if (index === -1) return null;
    return array[index];
  }

  snowSense.arrayHelper = {
    findIndex:  findIndex,
    findItemByValue:         findItemByValue,
  };

}());
