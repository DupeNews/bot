#!/usr/bin/env node

/**
 * Simple test script to verify the API is working
 */

const axios = require('axios');
const fs = require('fs');

const API_URL = 'http://localhost:3000';

async function testAPI() {
    console.log('ðŸ§ª Testing Prometheus Obfuscator API...\n');

    try {
        // Test 1: Health check
        console.log('1ï¸âƒ£ Testing health check...');
        const healthResponse = await axios.get(`${API_URL}/health`);
        console.log('âœ… Health check passed:', healthResponse.data.message);

        // Test 2: Get presets
        console.log('\n2ï¸âƒ£ Testing presets endpoint...');
        const presetsResponse = await axios.get(`${API_URL}/presets`);
        console.log('âœ… Presets retrieved:', presetsResponse.data.presets.join(', '));

        // Test 3: Obfuscate text
        console.log('\n3ï¸âƒ£ Testing text obfuscation...');
        const testCode = `
-- Test Lua script
local function greet(name)
    print("Hello, " .. name .. "!")
end

greet("API Test")
`;

        const textResponse = await axios.post(`${API_URL}/obfuscate-text`, {
            code: testCode,
            preset: 'Medium'
        });

        console.log('âœ… Text obfuscation successful');
        console.log('ðŸ“„ Obfuscated code preview:');
        console.log(textResponse.data.obfuscatedCode.substring(0, 200) + '...');

        // Test 4: File obfuscation
        console.log('\n4ï¸âƒ£ Testing file obfuscation...');
        
        // Create a test file
        const testFile = 'test_temp.lua';
        fs.writeFileSync(testFile, testCode);

        const FormData = require('form-data');
        const form = new FormData();
        form.append('file', fs.createReadStream(testFile));
        form.append('preset', 'Weak');

        const fileResponse = await axios.post(`${API_URL}/obfuscate`, form, {
            headers: form.getHeaders()
        });

        console.log('âœ… File obfuscation successful');
        console.log('ðŸ“ Original filename:', fileResponse.data.originalFilename);
        console.log('ðŸ”§ Preset used:', fileResponse.data.preset);

        // Clean up
        fs.unlinkSync(testFile);

        console.log('\nðŸŽ‰ All tests passed! The API is working correctly.');

    } catch (error) {
        console.error('\nâŒ Test failed:', error.message);
        
        if (error.response) {
            console.error('Response status:', error.response.status);
            console.error('Response data:', error.response.data);
        }
        
        if (error.code === 'ECONNREFUSED') {
            console.log('\nðŸ’¡ Make sure the API server is running:');
            console.log('   npm run build');
            console.log('   npm run start:api');
        }
    }
}

testAPI();
