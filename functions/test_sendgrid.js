const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp.sendgrid.net',
  port: 587,
  secure: false,
  auth: {
    user: 'apikey',
    pass: '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',
  },
});

const mailOptions = {
  from: '"NotaOK" <noreply@notaok.com>',
  to: 'claudemir.lima@gmail.com',
  subject: 'Teste SendGrid',
  text: 'Se voce recebeu este email, a chave SendGrid esta funcionando!',
};

transporter.sendMail(mailOptions)
  .then(() => {
    console.log('SUCCESS - SendGrid funcionando!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('ERRO - SendGrid com problema:', error.message);
    process.exit(1);
  });
