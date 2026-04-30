const { PDFImage } = require("pdf-image");
const esl = require("esl_symbolic");
let pdfImage = new PDFImage(esl.string("payload"));
pdfImage.numberOfPages()