#!/usr/bin/env node

const http = require('http');

async function testTokenSpeed(prompt, maxTokens = 100) {
  const startTime = Date.now();
  
  const data = JSON.stringify({
    messages: [
      {
        role: 'user',
        content: prompt
      }
    ],
    max_tokens: maxTokens,
    temperature: 0.7,
    top_p: 0.9,
    stream: false
  });

  const options = {
    hostname: 'localhost',
    port: 11434,
    path: '/v1/chat/completions',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': data.length
    }
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        const endTime = Date.now();
        const totalTime = endTime - startTime;
        
        try {
          const response = JSON.parse(responseData);
          const promptTokens = response.usage.prompt_tokens;
          const completionTokens = response.usage.completion_tokens;
          const totalTokens = response.usage.total_tokens;
          
          resolve({
            totalTime,
            promptTokens,
            completionTokens,
            totalTokens,
            content: response.choices[0].message.content,
            tokensPerSecond: (completionTokens / (totalTime / 1000)).toFixed(2)
          });
        } catch (error) {
          reject(error);
        }
      });
    });
    
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

async function runSpeedTests() {
  console.log('BitNet Token Generation Speed Test\n');
  console.log('==================================\n');
  
  const tests = [
    {
      name: 'Short Generation (20 tokens)',
      prompt: 'Write a haiku about technology.',
      maxTokens: 20
    },
    {
      name: 'Medium Generation (50 tokens)',
      prompt: 'Explain what machine learning is in simple terms.',
      maxTokens: 50
    },
    {
      name: 'Long Generation (100 tokens)',
      prompt: 'Tell me a story about a robot who learns to paint.',
      maxTokens: 100
    },
    {
      name: 'Very Long Generation (200 tokens)',
      prompt: 'Write a detailed explanation of how neural networks work, including the mathematics behind backpropagation.',
      maxTokens: 200
    }
  ];
  
  let totalStats = {
    totalTime: 0,
    totalCompletionTokens: 0,
    tests: []
  };
  
  for (const test of tests) {
    console.log(`Test: ${test.name}`);
    console.log('-'.repeat(50));
    
    try {
      const result = await testTokenSpeed(test.prompt, test.maxTokens);
      
      console.log(`Prompt tokens: ${result.promptTokens}`);
      console.log(`Completion tokens: ${result.completionTokens}`);
      console.log(`Total time: ${result.totalTime}ms`);
      console.log(`Token generation speed: ${result.tokensPerSecond} tokens/second`);
      console.log(`Response preview: "${result.content.substring(0, 60)}..."`);
      console.log('\n');
      
      totalStats.totalTime += result.totalTime;
      totalStats.totalCompletionTokens += result.completionTokens;
      totalStats.tests.push({
        name: test.name,
        tokensPerSecond: parseFloat(result.tokensPerSecond),
        completionTokens: result.completionTokens,
        promptTokens: result.promptTokens
      });
      
    } catch (error) {
      console.error(`Error in test: ${error.message}\n`);
    }
  }
  
  // Calculate overall statistics
  console.log('Overall Performance Summary');
  console.log('===========================\n');
  
  const avgTokensPerSecond = (totalStats.totalCompletionTokens / (totalStats.totalTime / 1000)).toFixed(2);
  console.log(`Total completion tokens generated: ${totalStats.totalCompletionTokens}`);
  console.log(`Total time: ${(totalStats.totalTime / 1000).toFixed(2)} seconds`);
  console.log(`Average token generation speed: ${avgTokensPerSecond} tokens/second\n`);
  
  console.log('Per-test breakdown:');
  totalStats.tests.forEach(test => {
    console.log(`- ${test.name}: ${test.tokensPerSecond} tokens/sec (${test.completionTokens} tokens)`);
  });
  
  // Performance assessment
  console.log('\nPerformance Assessment:');
  const avgSpeed = parseFloat(avgTokensPerSecond);
  if (avgSpeed > 30) {
    console.log('✅ Excellent: Token generation is very fast (>30 tokens/sec)');
  } else if (avgSpeed > 20) {
    console.log('✅ Good: Token generation is at expected speed (20-30 tokens/sec)');
  } else if (avgSpeed > 15) {
    console.log('⚠️  Fair: Token generation is slightly slow (15-20 tokens/sec)');
  } else {
    console.log('❌ Poor: Token generation is slow (<15 tokens/sec) - may need optimization');
  }
  
  // Check server logs for more detailed timing
  console.log('\nNote: Check server_restart.log for detailed per-token timing information');
}

// Run the tests
runSpeedTests().catch(console.error);