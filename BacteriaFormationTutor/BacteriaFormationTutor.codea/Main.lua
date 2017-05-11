-- Bacteria Formation Tutor
displayMode(FULLSCREEN_NO_BUTTONS)
-- Use this function to perform your initial setup
function setup()
    rectMode(CENTER)
    debugDraw = PhysicsDebugDraw()
    ellipseMode(CENTER)
    xw = WIDTH/1024
    if xw >= 1 then
        xw = 0.8
    end
    if HEIGHT/WIDTH < xw then
        xw = HEIGHT/WIDTH*0.8
    end
    cBody = 0
    touchMap = {}
    label = ""
    tutorial = false
    choices = {"diplococci","diplobacilli","streptococci","streptobacilli","staphylococci","staphylobacilli","tetrad","sarcina"}
--1: Is it in quiz screen, 2: is quizzing
    quiz = {false,false}
end

function orientationChanged( newOrientation )
    xw = WIDTH/1024
    if xw >= 1 then
        xw = 0.8
    end
    if HEIGHT/WIDTH < xw then
        xw = HEIGHT/WIDTH*0.8
    end
end

function choiceCheck(input)
    output = (input == label)
    if #quiz > 3 and output == false then
        for j=3,#quiz do
            if quiz[j] == input then
                output = true
            end
        end
    end
    return output
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color
    background(255, 255, 255, 255)
    fill(0)
    if tutorial then
        sprite("Project:tutorial",WIDTH/2,HEIGHT/2,WIDTH*3/4)
    elseif quiz[1] then
        if quiz[3] == nil then
            for i=3,6 do
                temp = math.random(1,#choices)
                while choiceCheck(choices[temp]) do
                     temp = math.random(1,#choices)
                end
                quiz[i] = choices[temp]
            end
            quiz[math.random(3,6)] = label
        end
        debugDraw:draw()
        fontSize(70*xw)
        text("What is this formation?",WIDTH/2,HEIGHT*7/8)
        for i=3,6 do
            --tint(255)
            fill(0,90,255,125)
            strokeWidth(0)
            rect(WIDTH/2,HEIGHT*7.3/8-(i-2)*HEIGHT/5,WIDTH*7/8,HEIGHT/6)
            fill(0)
            --sprite("Project:box",WIDTH/2,HEIGHT*7/8-(i-2)*HEIGHT/5,WIDTH*7/8,HEIGHT/6)
            text(quiz[i],WIDTH/2,HEIGHT*7.3/8-(i-2)*HEIGHT/5)
        end
    else
        debugDraw:draw()
        spriteMode(CENTER)
        sprite("Project:coc",WIDTH/5,HEIGHT/8,100*xw)
        -- ellipse(WIDTH/4,HEIGHT/8,100*xw)
        sprite("Project:bac",WIDTH*3/5,HEIGHT/8,100*xw,200*xw)
        --ellipse(WIDTH*3/4,HEIGHT/8,100*xw,200*xw)
        fontSize(100*xw)
        text("✖️",WIDTH*2/5,HEIGHT/8)
        if quiz[2] then
        fill(0,255,0,255)
        else
        fill(255,0,0,255)
        end
        text("?",WIDTH*4/5,HEIGHT/8)
        fill(0)
        
        text(label, WIDTH/2,HEIGHT/3.6)
        
        if CurrentTouch.state == ENDED then
        detection()
        tutorial = false
        end
        
        fontSize(40*xw)
        text("tap and hold here for more information",WIDTH/2,HEIGHT*7/8)
        -- print(#debugDraw.joints)
        
        
        -- This sets the line thickness
        strokeWidth(5)
        
    end
    -- Do your drawing here
    
end

function detection()
    --for t, joint in ipairs(debugDraw.joints) do
    
    if #debugDraw.joints == 1 then
        if label ~= "diplo"..debugDraw.joints[#debugDraw.joints].bodyA.info then
            label = "diplo"..debugDraw.joints[#debugDraw.joints].bodyA.info
            if quiz[2] then
                quiz[1] = true
            else
            if debugDraw.joints[#debugDraw.joints].bodyA.info == "cocci" then
                speech.say("dip low cox eye")
            else
                speech.say("dip low bass sill eye")
            end
            end
        end
    elseif strepCheck() then
        if label ~="strepto"..debugDraw.joints[#debugDraw.joints].bodyA.info then
            label ="strepto"..debugDraw.joints[#debugDraw.joints].bodyA.info
if quiz[2] then
quiz[1] = true
else
            if debugDraw.joints[#debugDraw.joints].bodyA.info == "cocci" then
                speech.say("strehp toe cox eye")
            else
                speech.say("strep toe bass sill eye")
            end
            end
        end
    elseif staphCheck() then
        if label ~="staphylo"..debugDraw.joints[#debugDraw.joints].bodyA.info then
            label ="staphylo"..debugDraw.joints[#debugDraw.joints].bodyA.info
if quiz[2] then
quiz[1] = true
else
            if debugDraw.joints[#debugDraw.joints].bodyA.info == "cocci" then
                speech.say("staff ill low cox eye")
            else
                speech.say("staff ill low bass sill eye")
            end
end
        end
    elseif tetCheck() then
        if label ~= "tetrad" then
if quiz[2] then
quiz[1] = true
else
            speech.say("teh trahd")
end
            label = "tetrad"
        end
    elseif sarCheck() then
        if label ~= "sarcina" then
            label = "sarcina"
if quiz[2] then
quiz[1] = true
else
            speech.say("sahr sih knee")
end
        end
    else
        label = ""
    end
    
    --  end
end

function sarCheck()
    if  #debugDraw.bodies == 8 then
        output = true
        for i = 1,#debugDraw.joints do
            if debugDraw.joints[i].bodyA.info ~= "cocci" or debugDraw.joints[i].bodyB.info ~= "cocci" then
                output = false
            end
        end
        collisionCounter = collisions()
        --  collisionCounter = mapCount(collisionCounter)
        --if  then
        return output and zeroCount(collisionCounter) == 0
    else
        return false
    end
end

function tetCheck()
    if #debugDraw.joints == 4 then
        return #debugDraw.bodies == 4 and debugDraw.joints[1].bodyA.info == "cocci"
    else
        return false
    end
    --  collisionCounter = collisions()
    --collisionCounter = mapCount(collisionCounter)
    --  if collisionCounter[]
    -- end
end

function staphCheck()
    if #debugDraw.joints ~= 18 then
        return false
        
    else
        collisionCounter = collisions()
        collisionCounter = mapCount(collisionCounter)
        -- print(collisionCounter[1])
        --print(collisionCounter[5])
        return (collisionCounter[1] == nil and collisionCounter[2] == 3 and collisionCounter[3] == nil and collisionCounter[4] == 6  and collisionCounter[6] == 1)
    end
end

function mapCount(collisions)
    output = {}
    for i = 1, #debugDraw.bodies do
        if collisions[i] ~= nil then
            if output[collisions[i]] ~= nil then
                output[collisions[i]] = output[collisions[i]] + 1
            else
                output[collisions[i]] = 1
            end
        end
    end
    return output
end

function zeroCount(collisions)
    output = 0
    for i = 1, #debugDraw.bodies do
        if collisions[i] == nil then
            output = output+1
        end
    end
    return output
end

function collisions()
    collisionCounter = {}
    
    for i,joint in ipairs(debugDraw.joints) do
        for b,body in ipairs(debugDraw.bodies) do
            if body == joint.bodyA or body == joint.bodyB then
                if collisionCounter[b] == nil then
                    collisionCounter[b] = 1
                else
                    collisionCounter[b] = collisionCounter[b] + 1
                end
            end
        end
    end
    return collisionCounter
end

function strepCheck()
    if #debugDraw.joints < 2 or #debugDraw.bodies < 6 then
        return false
    else
        collisionCounter = collisions()
        flag = true
        one = 0
        two = 0
        for i = 1, #debugDraw.bodies do
            if collisionCounter[i] == 1 then
                
                one = one + 1
            elseif collisionCounter[i] == 2 then
                two = two + 1
            else
                flag = false
            end
        end
        -- print(one)
        if one ~= 2 then
            flag = false
        end
        return flag
    end
end


function touched(touch)
    if quiz[1] then
        if touch.state == BEGAN then
            for i=3,6 do
               if touch.y > HEIGHT*7.3/8-(i-2)*HEIGHT/5-HEIGHT/12 and touch.y < HEIGHT*7.3/8-(i-2)*HEIGHT/5+HEIGHT/12 then
                    if quiz[i] == label then
                        quiz[1] = false
                        speech.say("correct!")
                    else
                        speech.say("try again")
                    end
                end
            end
        end
    else
    flag = false
    if touch.state == BEGAN then
        if touch.y > HEIGHT/8-100*xw and touch.y < HEIGHT/8+100*xw then
            if touch.x > WIDTH/5-100*xw and touch.x < WIDTH/5+100*xw  then
                createCircle(WIDTH/4,HEIGHT/8,100*xw,"cocci")
                touchMap[touch.id] = cBody
            elseif touch.x > WIDTH*2/5-100*xw and touch.x < WIDTH/5*2+100*xw then
                debugDraw:clear()
                touchMap = {}
            elseif touch.x > WIDTH/5*3-100*xw and touch.x < WIDTH/5*3+100*xw then
                createBox(WIDTH/4,HEIGHT/8,100*xw,200*xw,"bacilli")
                touchMap[touch.id] = cBody
            elseif touch.x > WIDTH/5*4-100*xw and touch.x < WIDTH/5*4+100*xw then
                quiz[2] = (quiz[2] == false)
            end
        elseif touch.y > HEIGHT/8*7-40*xw then
            tutorial = true
        end
        detectTouch(touch)
    elseif touch.state == ENDED and tutorial then
        tutorial = false
    end
    
    
    if touch.state == ENDED then
        touchMap[touch.id] = nil
    elseif touchMap[touch.id] ~= nil then
        debugDraw.bodies[touchMap[touch.id]].x = touch.x
        debugDraw.bodies[touchMap[touch.id]].y = touch.y
    end
    end
end

function detectTouch(touch)
    for i,body in ipairs(debugDraw.bodies) do
        if touch.x > body.x-100*xw and touch.x < body.x+100*xw and touch.y > body.y-100*xw and touch.y < body.y+100*xw then
            touchMap[touch.id] = i
            break
        end
    end
end

function createCircle(x,y,r,info)
    local circle = physics.body(CIRCLE, r/2)
    -- enable smooth motion
    circle.interpolate = true
    circle.x = x
    circle.y = y
    circle.restitution = 0
    circle.friction = 0.4
    circle.gravityScale = 0
    circle.sleepingAllowed = false
    circle.info = info
    debugDraw:addBody(circle)
    cBody = #debugDraw.bodies
    
    return circle
end

function createBox(x,y,w,h,info)
    -- polygons are defined by a series of points in counter-clockwise order
    local box = physics.body(POLYGON, vec2(-w/2,h/2), vec2(-w/2,-h/2), vec2(w/2,-h/2), vec2(w/2,h/2))
    box.interpolate = true
    box.x = x
    box.y = y
    box.restitutions = 0
    box.friction = 0.4
    box.gravityScale = 0
    box.sleepingAllowed = false
    box.info = info
    debugDraw:addBody(box)
    cBody = #debugDraw.bodies
    return box
end

function collide(contact)
    if debugDraw then
        debugDraw:collide(contact)
    end
end
