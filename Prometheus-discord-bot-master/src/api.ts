import 'dotenv/config';
import express from 'express';
import multer from 'multer';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import tmp from 'tmp';
import '@colors/colors';
import logger from './logger';
import obfuscate from './obfuscate';

const app = express();
const port = process.env.API_PORT || 3000;
const MAX_SIZE = 40000; // 40kB max size

// Configure multer for file uploads
const upload = multer({
    limits: {
        fileSize: MAX_SIZE,
    },
    fileFilter: (req, file, cb) => {
        // Only allow .lua files
        if (path.extname(file.originalname).toLowerCase() === '.lua') {
            cb(null, true);
        } else {
            cb(new Error('Only .lua files are allowed'));
        }
    },
});

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ status: 'ok', message: 'Prometheus Obfuscator API is running' });
});

// Get available presets
app.get('/presets', (req, res) => {
    const presets = ['Weak', 'Medium', 'Strong', 'Minify'];
    res.json({ presets });
});

// Obfuscate endpoint
app.post('/obfuscate', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ 
                error: 'No file uploaded. Please upload a .lua file.' 
            });
        }

        const preset = req.body.preset || 'Medium';
        const validPresets = ['Weak', 'Medium', 'Strong', 'Minify'];
        
        if (!validPresets.includes(preset)) {
            return res.status(400).json({ 
                error: `Invalid preset. Valid presets are: ${validPresets.join(', ')}` 
            });
        }

        // Create temporary file for the uploaded content
        const inputFile = tmp.fileSync({ postfix: '.lua' });
        fs.writeFileSync(inputFile.name, req.file.buffer);

        logger.log(`Obfuscating file with ${preset} preset`);

        // Obfuscate the file
        const outputFile = await obfuscate(inputFile.name, preset);
        
        // Read the obfuscated content
        const obfuscatedContent = fs.readFileSync(outputFile.name, 'utf8');
        
        // Clean up temporary files
        inputFile.removeCallback();
        outputFile.removeCallback();

        // Return the obfuscated content
        res.json({
            success: true,
            preset: preset,
            originalFilename: req.file.originalname,
            obfuscatedCode: obfuscatedContent
        });

    } catch (error) {
        logger.error(`Obfuscation failed: ${error}`);
        res.status(500).json({ 
            error: 'Obfuscation failed', 
            details: error.toString() 
        });
    }
});

// Obfuscate from text endpoint (for direct code input)
app.post('/obfuscate-text', async (req, res) => {
    try {
        const { code, preset = 'Medium' } = req.body;

        if (!code) {
            return res.status(400).json({ 
                error: 'No code provided. Please include "code" in the request body.' 
            });
        }

        const validPresets = ['Weak', 'Medium', 'Strong', 'Minify'];
        
        if (!validPresets.includes(preset)) {
            return res.status(400).json({ 
                error: `Invalid preset. Valid presets are: ${validPresets.join(', ')}` 
            });
        }

        // Check code size
        if (Buffer.byteLength(code, 'utf8') > MAX_SIZE) {
            return res.status(400).json({ 
                error: `Code too large. Maximum size is ${MAX_SIZE} bytes.` 
            });
        }

        // Create temporary file for the code
        const inputFile = tmp.fileSync({ postfix: '.lua' });
        fs.writeFileSync(inputFile.name, code);

        logger.log(`Obfuscating code with ${preset} preset`);

        // Obfuscate the file
        const outputFile = await obfuscate(inputFile.name, preset);
        
        // Read the obfuscated content
        const obfuscatedContent = fs.readFileSync(outputFile.name, 'utf8');
        
        // Clean up temporary files
        inputFile.removeCallback();
        outputFile.removeCallback();

        // Return the obfuscated content
        res.json({
            success: true,
            preset: preset,
            obfuscatedCode: obfuscatedContent
        });

    } catch (error) {
        logger.error(`Obfuscation failed: ${error}`);
        res.status(500).json({ 
            error: 'Obfuscation failed', 
            details: error.toString() 
        });
    }
});

// Error handling middleware
app.use((error: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
    if (error instanceof multer.MulterError) {
        if (error.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({ 
                error: `File too large. Maximum size is ${MAX_SIZE} bytes.` 
            });
        }
    }
    
    logger.error(`API Error: ${error.message}`);
    res.status(500).json({ 
        error: 'Internal server error', 
        details: error.message 
    });
});

// Start the server
app.listen(port, () => {
    logger.log(`ðŸš€ Prometheus Obfuscator API server running on port ${port.toString().cyan}`);
    logger.log(`ðŸ“– API Documentation:`);
    logger.log(`   GET  /health - Health check`);
    logger.log(`   GET  /presets - Get available presets`);
    logger.log(`   POST /obfuscate - Upload .lua file for obfuscation`);
    logger.log(`   POST /obfuscate-text - Send code directly for obfuscation`);
});

export default app;
