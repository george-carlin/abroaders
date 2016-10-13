import ReactTools from 'react-tools';

module.exports = {
  process(src) {
    return ReactTools.transform(src);
  },
};
